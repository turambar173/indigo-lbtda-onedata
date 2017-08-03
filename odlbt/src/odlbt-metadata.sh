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

metadataAdd(){
    ###
    # metadataAdd
    ###
    local metadataFile=$1
    
    # Store in tmp only the metadata
    jq 'del(.file_name)' $metadataFile > $tmp
    file_name=$(jq -r '.file_name' $metadataFile)
    
    
    local ACCESS_TOKEN=`getUserToken $user`
    local providerIp=$(getProviderIp ${providerName})

    local TOKEN_HEADER="X-Auth-Token: $ACCESS_TOKEN"
    local CDMI_VSN_HEADER="X-CDMI-Specification-Version: 1.1.1"
    local ENDPOINT=https://${providerIp}:8443/cdmi

    curl -k -H "$TOKEN_HEADER" -H "$CDMI_VSN_HEADER" \
            -H "Content-Type: application/cdmi-object" \
            -d "$(cat ${tmp})" \
            -X PUT ${ENDPOINT}/${spaceName}/${file_name}
#    echo
#    cat $tmp
#    echo
#    echo $TOKEN_HEADER
#    echo $spaceName
#    echo $file_name
#    echo $ENDPOINT

    # Clean tmp
    rm -f $tmp

}

# Funzione di utilizzo
# Seguendo il modello scrivi
# - tutte le opzioni che si possono usare
# - i modi in cui e' possibile eseguire il programma
# - la descrizione delle opzioni
usage() {
  
  cat<<EOF
Usage: ${0##*/} [--help | -h]
       ${0##*/} add -p <provider-name> -s <space-name> <file.json>...

This script adds metadata to files uploaded in OneData.

Examples:
${0##*/} add -p Trieste -s INAF/2014 file.json

    Add metadata contained in the file.json to the corresponding file
    uploaded in INAF/2014 in the Trieste provider. The input json file
    is formatted like

    {
        "file_name": "luci.20141220.0001.fits",
        "metadata": {
            "DATE-OBS": "2014-12-20T04:48:01.4824",
            "DEC": "+20:33:56.820488380",
            "EXPTIME": 300.0,
            "INSTRUME": "Lucifer",
            "MJD-OBS": 57011.20001716,
            "PARTNER": "AZ,INAF,LBTB,OSURC",
            "PI_NAME": "DThompson",
            "RA": "02:54:17.545028330"
        }
    }


Options:
  -h, --help                display this help and exit
  -p <provider-name>        the name of the Oneprovider you want
                            to connect to
  -s <space-name>           the name of the spaces where data are,
                            it must include the full path
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
      -p|--provider)
        providerName=$2
        shift
        ;;
      -s|--space)
        spaceName=$2
        shift
        ;;
      -?*)
        echo "Unknown option $1" >&2
        exit 1
        ;;
      *)
        if [[ $command ]]; then
          input="${input} $1"
        elif [[ $1 == 'add' ]]; then
          command=$1
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
    if [[ ! $input ]]; then
      echo "Missing input metadata json file" >&2
      exit 1
    fi
    if [[ ! $providerName ]]; then
      echo "Missing input provider name" >&2
      exit 1
    fi
    if [[ ! $spaceName ]]; then
      echo "Missing input space name" >&2
      exit 1
    fi
    for f in $input; do
      metadataAdd $f
    done
  fi
  
  exit 0
  
}

# Usa questo if se il comando deve essere usato con degli input
if (( $# )); then
  main "$@"
else
  usage
fi
