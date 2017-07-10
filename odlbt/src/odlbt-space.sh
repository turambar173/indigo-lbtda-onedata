#!/bin/bash

# Decommenta queste righe se vuoi importare gli alias di bashrc
# shopt -s expand_aliases
# source ~/.bashrc

# Definisci gli alias
# alias myalex='mysql --defaults-group-suffix=alex'

# Importa le librerie sh in questo modo
# . metaLib.sh

# Definisci dei tmp
tmp=/tmp/$RANDOM

# Definisci il PREFIX
PREFIX=$(dirname $(dirname $(realpath $0)))
. ${PREFIX}/lib/odlbt-lib.sh

# Pulizia
# pulizia(){
# }

spaceAdd(){
    ###
    #
    ###
    
    local userCredential=`getCredential $user`
    
    echo '{"name":"'$spaceName'"}' > $tmp
    
    curl -ku ${userCredential} -H "Content-type: application/json" \
        -X POST -d "$(cat $tmp)" \
        https://${ONEZONE}:8443/api/v3/onezone/spaces
    
    rm -f $tmp

}

spaceGetId(){
    ###
    #
    #
    # - get list of all spaces by id
    ###
    
    local userCredential=`getCredential $user`
    local spaces
    local spaceId

    spaces=$(curl -ku ${userCredential} -X GET \
        https://${ONEZONE}:8443/api/v3/onezone/spaces 2> /dev/null | jq '.')
        
    for spaceId in `echo $spaces | jq -r '.spaces[]'`; do
        name=$(curl -ku ${userCredential} -X GET \
          https://${ONEZONE}:8443/api/v3/onezone/spaces/${spaceId} \
          2> /dev/null | jq -r '.name')
        if [[ $name == $spaceName ]]; then
            echo $spaceId
            return
        fi
    done
    
}

spaceGetToken(){
    ###
    #
    ###
    local userCredential=`getCredential $user`
    local spaceId
    
    spaceId=$(spaceGetId ${spaceName})
    
    curl -ku ${userCredential} -X GET \
        https://${ONEZONE}:8443/api/v3/onezone/spaces/${spaceId}/providers/token \
        2> /dev/null | jq -r '.token'
 
}

storageGetId(){

    local providerIp=$1
    curl -ku admin:password -H "Content-type: application/json" \
    https://${providerIp}:9443/api/v3/onepanel/provider/storages \
    2> /dev/null | jq -r '.ids[0]'
}

spaceSupport(){
    ###
    #
    ###

    local userCredential=`getCredential $user`
    local spaceToken=$(spaceGetToken ${spaceName})
    local providerIp=$(getProviderIp ${providerName})
    local sizeM=$(echo $size | awk '{print $1*1000000}')

    local storageId=$(storageGetId ${providerIp})

    echo '{ "storageId" : "'${storageId}'",
        "token": "'${spaceToken}'",
        "size" : '${sizeM}' }' > $tmp

    curl -ku ${userCredential} -H "Content-type: application/json" \
        -X POST -d "$(cat $tmp)" \
        https://${providerIp}:9443/api/v3/onepanel/provider/spaces > /dev/null

}

# Funzione di utilizzo
# Seguendo il modello scrivi
# - tutte le opzioni che si possono usare
# - i modi in cui e' possibile eseguire il programma
# - la descrizione delle opzioni
usage() {
  
  cat<<EOF
Usage: ${0##*/} [--help | -h]
       ${0##*/} [--user | -u <user-name>] add <space-name>
       ${0##*/} [--user | -u <user-name>] get <space-name> token
       ${0##*/} [--user | -u <user-name>] get <space-name> id
       ${0##*/} support <space-name> <provider-name> <size>

This script creates and manages OneData spaces.

Examples:
${0##*/} add INAF

    Create the space INAF

${0##*/} support INAF Trieste 1024

    Support the space INAF with the Trieste providere with 1024 MB
    
${0##*/} get INAF token

    Print the token of the INAF space
    
${0##*/} get INAF id

    Print the id of the INAF space
    
Options:
  -h, --help                display this help and exit
  -u, --user <user-name>    use <user-name> instead of admin to create
                            and manage spaces
EOF
  
    exit 0

}

# Funzione main
main() {

  # Variabili locali
  # Imposta i valori di default
  user=admin
  size=1
  
  while (( $# )); do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      -u|--user)
        user=$2
        shift
        ;;
      -?*)
        echo "Unknown option $1" >&2
        exit 1
        ;;
      *)
        if [[ $1 == 'add' ]]; then
          command=$1
          spaceName=$2
          shift
        elif [[ $1 == 'get' ]]; then
          if [[ $3 == 'id' || $3 == 'token' ]]; then
            command=${1}${3}
            spaceName=$2
          elif [[ ! $3 ]]; then
            echo "Missing what you want to get (id, token)" >&2
            exit 1
          else
            echo "Unknown command $3" >&2
            exit 1
          fi
          shift; shift
        elif [[ $1 == 'support' ]]; then
          command=$1
          spaceName=$2
          providerName=$3
          size=$4
          shift; shift; shift
        else
          echo "Unknown command $1" >&2
          exit 1
        fi
		;;
    esac
    shift
  done
  
  if [[ $command == 'add' ]]; then
    # Usa questo if se vuoi verificare che l'input sia stato settato
    if [[ ! $spaceName ]]; then
      echo "Missing input space name" >&2
      exit 1
    fi
    spaceAdd
  elif [[ $command == 'getid' ]]; then
    # Usa questo if se vuoi verificare che l'input sia stato settato
    if [[ ! $spaceName ]]; then
      echo "Missing input space name" >&2
      exit 1
    fi
    spaceGetId
  elif [[ $command == 'gettoken' ]]; then
    # Usa questo if se vuoi verificare che l'input sia stato settato
    if [[ ! $spaceName ]]; then
      echo "Missing input space name" >&2
      exit 1
    fi
    spaceGetToken
  elif [[ $command == 'support' ]]; then
    # Usa questo if se vuoi verificare che l'input sia stato settato
    if [[ ! $spaceName ]]; then
      echo "Missing input space name" >&2
      exit 1
    fi
    if [[ ! $providerName ]]; then
      echo "Missing input provider name" >&2
      exit 1
    fi
    spaceSupport
  fi
  
}

# Usa questo if se il comando deve essere usato con degli input
if (( $# )); then
  main "$@"
else
  usage
fi
