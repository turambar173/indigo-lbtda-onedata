#!/bin/bash

# Scenario has to be defined before the source
SCENARIO_NAME='30oneprovideronezonemultihost'

PREFIX=$(dirname $(realpath $0))
cd ${PREFIX}
source ../bin/run_onedata.sh

clean_scenario() {
  : # pass
}

main "$@"
