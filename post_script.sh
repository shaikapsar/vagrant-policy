#!/usr/bin/env bash
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

sudo docker exec -t drools bash
    rm -rf /tmp/apps-controlloop
    mkdir /tmp/apps-controlloop
    cd /tmp/apps-controlloop
    rm -rf /tmp/basex-controlloop
    mkdir /tmp/basex-controlloop
exit

sudo docker cp /home/vagrant/.m2/repository/org/onap/policy/drools-applications/controlloop/packages/apps-controlloop/*/apps-controlloop-*.zip drools:/tmp/apps-controlloop/apps-controlloop.zip
sudo docker cp /home/vagrant/.m2/repository/org/onap/policy/drools-applications/controlloop/packages/basex-controlloop/*/basex-controlloop-*.tar.gz drools:/tmp/basex-controlloop/basex-controlloop.tar.gz

sudo docker exec -t drools bash
  cd /tmp/apps-controlloop/ 
  unzip apps-controlloop.zip
  cd /tmp/basex-controlloop
  tar zxvf basex-controlloop.tar.gz
exit 

sudo docker cp ./apps-controlloop-installer drools:/tmp/apps-controlloop/apps-controlloop-installer

sudo docker exec -t drools bash
  cd /tmp/apps-controlloop/
  policy stop
  ./apps-controlloop-installer
  policy start
  features status
exit 
