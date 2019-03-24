str#!/usr/bin/env bash
# Copyright 2018 AT&T Intellectual Property. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

sudo apt-get update -y
sudo apt-get install -y maven openjdk-8-jdk npm python-pip docker.io
sudo pip install docker-compose
cd $HOME
if [  ! -d oparent ] ; then
git clone http://gerrit.onap.org/r/oparent
fi
cd oparent
git checkout casablanca
mkdir -p $HOME/.m2

cp $HOME/oparent/settings.xml $HOME/.m2

cd $HOME
if [  ! -d docker ] ; then
git clone https://github.com/shaikapsar/vagrant-policy docker

fi
cd docker
git pull

for comp in common drools-pdp drools-applications engine
do
    cd $HOME
        if [  ! -d $comp ] ; then
            git clone http://gerrit.onap.org/r/policy/$comp
        fi
    pushd $HOME/$comp
    git checkout casablanca
    git pull
    if [[ $comp == "drools-pdp" ]]; then
        cp $HOME/docker/Dockerfile.pdpd $HOME/$comp/packages/docker/src/main/docker/Dockerfile
    fi
    mvn clean install -Dmaven.test.skip=true
    popd
done

pushd $HOME/engine/packages/docker/target/
   sudo docker build -t onap/policy-pe policy-pe
popd

pushd $HOME/drools-pdp/packages/docker/target/
    sudo docker build -t onap/policy-drools policy-drools
popd

cd $HOME/docker

chmod +x config/drools/drools-tweaks.sh
echo 192.168.56.10 > config/pe/ip_addr.txt
export MTU=1500
pushd $HOME/docker/dmaap
sudo -E docker-compose up -d
popd
#Generate topics
declare -a arr=(PDPD-CONFIGURATION unauthenticated.DCAE_CL_OUTPUT APPC-CL APPC-LCM-WRITE SDNR-CL-RSP); for topic in "${arr[@]}"; do \
  curl -X POST -H "Content-Type: application/json" -d \
    '{"topicName":"'"$topic"'","partitionCount":"1","replicationCount":"1","transactionEnabled":"false"}' "http://localhost:3904/topics/create"; \
done

sudo -E docker-compose up -d

chmod +x ./post_script.sh

#./post_script.sh
