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
. ${PREFIX}/lib/odlbt-lib.sh

# Pulizia
# pulizia(){
# }

userAdd(){
    ###
    #
    ###
    
    userCredential=`getCredential $user`
    
    curl -X POST -ku ${userCredential} \
        -H "content-type: application/json" -d "$(cat $input)" \
        https://${ONEZONE}:9443/api/v3/onepanel/users

}

getToken(){
    ###
    # getToken
    #
    # Print to STDOUT the token of the input user
    ###
    
    getUserToken $user
    
}
# Funzione di utilizzo
# Seguendo il modello scrivi
# - tutte le opzioni che si possono usare
# - i modi in cui e' possibile eseguire il programma
# - la descrizione delle opzioni
usage() {
  
  cat<<EOF
Usage: ${0##*/} [--help | -h]
       ${0##*/} add <user.json>
       ${0##*/} get token <user-name>

This script creates and manages OneData users.

Examples:
${0##*/} add user.json

    Create in OneZone the login credendials for the user contained
    in the file user.json. The input json file is formatted like

	{
		"username" : "<username>",
		"password" : "<password>",
		"userRole" : "admin"
	}

${0##*/} get token admin

	Get the access token for admin from the configuration file, and
	print it to STDIN. Do not generate a new access token, simply
	get the one already saved in the configuration file.



Options:
  -h, --help       display this help and exit
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
      -?*)
        echo "Unknown option $1" >&2
        exit 1
        ;;
      *)
        if [[ $1 == 'add' ]]; then
          command=$1
          input=$2
          shift
        elif [[ $1 == 'get' ]]; then
          command=$1
          what=$2
          user=$3
          shift; shift
        else
          echo "Unknown command $1" >&2
        fi
		;;
    esac
    shift
  done
  
  # Rimuove gli spazi iniziali dalla stringa input
  input=${input# }

  if [[ $command == 'add' ]]; then
    # Usa questo if se vuoi verificare che l'input sia stato settato
    if [[ ! $input ]]; then
      echo "Missing input file" >&2
      exit 1
    fi
    userAdd
  elif [[ $command == 'get' ]]; then
    if [[ ! $what ]]; then
      echo "Missing what you want to get" >&2
      exit 1
    fi
    if [[ $what == 'token' ]]; then
      if [[ ! $user ]]; then
        echo "Missing user name" >&2
        exit 1
      fi
      getToken
    fi
  fi
  
}

# Usa questo if se il comando deve essere usato con degli input
if (( $# )); then
  main "$@"
else
  usage
fi
