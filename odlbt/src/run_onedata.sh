#!/bin/bash

# Decommenta queste righe se vuoi importare gli alias di bashrc
# shopt -s expand_aliases
# source ~/.bashrc

# Definisci gli alias
# alias myalex='mysql --defaults-group-suffix=alex'

# Importa le librerie sh in questo modo
# . metaLib.sh

# Definisci dei tmp
# tmp=$RANDOM

# Definisci il PREFIX
PREFIX=$(dirname $(dirname $(realpath $0)))
SCENARIOS_DIR=${PREFIX}/scenarios

# Pulizia
# pulizia(){
# }

# Funzione di utilizzo
# Seguendo il modello scrivi
# - tutte le opzioni che si possono usare
# - i modi in cui e' possibile eseguire il programma
# - la descrizione delle opzioni
usage() {
  
  cat<<EOF
Usage: ${0##*/} [-h | --help]
       ${0##*/} <scenario> zone
       ${0##*/} <scenario> provider <provider-name>

This script deploys OneData components as docker containers.
Only root che run this script.

Examples:
${0##*/} scenario2.0 zone

    Deploy Onezone for scenario2.0
    
${0##*/} scenario3.0 provider Trieste

    Deploy Trieste provider for scenario2.0

Options:
  -h, --help       display this help and exit
EOF
  
    exit 0

}


deploy-zone(){
    ###
    # deploy-zone
    ###
    

    # Convert scenario like 2.0 -> 2_0
    scenario=${scenario/./_}
    
    # Run onezone
    runner=${SCENARIOS_DIR}/scenario${scenario}_onezone/run_onedata.sh
    ${runner} --zone
    
}


deploy-provider(){
    ###
    # deploy-provider
    ###
    
    local provider=$1
    
    # Convert scenario like 2.0 -> 2_0
    scenario=${scenario/./_}
    
    runner=${SCENARIOS_DIR}/scenario${scenario}_${provider}/run_onedata.sh
    ${runner} --provider
    
}

main() {
  ###
  # main
  ###

  # Verifica che sei root
  if [ "$(whoami)" != root ]; then
    echo "This script must be run as root!" >&2
    exit 1
  fi


  # Variabili locali
  # Imposta i valori di default
  local command
  local clean=0
  
  while (( $# )); do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      scenario*)
        if [[ ! $scenario ]]; then
          scenario=${1#scenario}
          if [[ $scenario != "2.0" && $scenario != "3.0" ]]; then
            echo "Unknown scenario$scenario" >&2
            exit 1
          fi
        else
          echo "Scenario already set to scenario$scenario" >&2
          exit 1
        fi
        ;;
      zone)
        command=deploy-zone
        ;;
      provider)
        command="deploy-provider $2"
        shift
        ;;
      *)
        echo "Unknown option $1" >&2
        exit 1
        ;;
    esac
    shift
  done

  # Check scenario is set
  if [[ ! $scenario ]]; then
    echo "Scenario is not defined" >&2
    exit 1
  fi
  
  # Run the command
  $command $scenario
  
}

if [ "$(whoami)" != root ]; then
  echo "This script must be run as root!" 1>&2
  exit 1
fi

# Usa questo if se il comando deve essere usato con degli input
if (( $# )); then
  main "$@"
else
  usage
fi
