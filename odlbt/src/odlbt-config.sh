#!/bin/bash

# Decommenta queste righe se vuoi importare gli alias di bashrc
# shopt -s expand_aliases
# source ~/.bashrc

# Definisci gli alias
# alias myalex='mysql --defaults-group-suffix=alex'

# Importa le librerie sh in questo modo
# . metaLib.sh

# Definisci dei tmp
tmp=$RANDOM

# Definisci il PREFIX
PREFIX=$(dirname $(dirname $(realpath $0)))
. ${PREFIX}/lib/odlbt-lib.sh


# Pulizia
#pulizia(){
#}

configUser(){
    ###
    # Write the input json to the output file
    #
    # - check the input file
    # - add the user to output
    ###
    
    checkInput
    newUser='{'$(jq '.username' $input)' : '$(cat $input)'}'

    if [[ -s $output ]]; then
        cat $output | jq ".users += ${newUser}" > $tmp
        mv $tmp $output
    else
        echo '{ "users" : '${newUser}' }' > $output
    fi
}

configToken(){
    ###
    # Write the user token to the output file
    #
    # - check the input file
    # - add the user to output
    ###
    
    local userCredential=`getCredential $user`
    local token

    if [[ $userCredential == ":" ]]; then
        echo "The user $user does not exist in configuration file $output" 2> /dev/null
        exit 1
    fi

    token=`createUserToken $user`

    cat $output | jq ".users.$user += { \"token\" : \"$token\" }" > $tmp
    mv $tmp $output
    
}


configProvider(){
    ###
    # Write the input provider to the output file
    #
    # - add the provider to output
    ###
    
    newProvider='{ "'${providerName}'" : 
        { "name" : "'${providerName}'",
          "ip" : "'${providerIp}'" }}'
    
    if [[ -s $output ]]; then
        cat $output | jq ".oneproviders += ${newProvider}" > $tmp
        mv $tmp $output
    else
        echo '{ "oneproviders" : '${newProvider}' }' > $output
    fi
}

checkInput(){
    ###
    # Check the input file
    # 
    # - check file exists
    # - check json has username and password keys
    ###
    
    if [[ ! -e $input ]]; then
        echo "File $input does not exist" >&2
        exit 1
    fi

    if [[ $(jq '.username' $input) == null ]]; then
        echo "Missing username in $input" >&2
        exit 1
    fi

    if [[ $(jq '.password' $input) == null ]]; then
        echo "Missing password in $input" >&2
        exit 1
    fi

}

configZone(){
    ###
    # Write the input IP of the zone to the output file
    #
    # - add the zone IP to output
    ###
    
    if [[ -s $output ]]; then
        cat $output | jq '. + { "onezone" : "'$zoneIp'" }' > $tmp
        mv $tmp $output
    else
        echo '{ "onezone" : "'$zoneIp'" }' > $output
    fi
}

usage() {
    ###
    # Funzione di utilizzo
    # Seguendo il modello scrivi
    # - tutte le opzioni che si possono usare
    # - i modi in cui e' possibile eseguire il programma
    # - la descrizione delle opzioni
    ###
    
  cat<<EOF
Usage: ${0##*/} [--help | -h]
       ${0##*/} [--global | -g] user <user.json>
       ${0##*/} [--global | -g] zone <onezone-ip>
       ${0##*/} [--global | -g] provider <provider-name> <provider-ip>
       ${0##*/} [--global | -g] token <user-name>

This script configures the odlbt package. If the option --global is set
configurations are saved ~/.odlbtconfig, otherwise they are saved in the
current directory in ./config.

Examples:
${0##*/} user user.json

    Add the login credendials contained in the file user.json to
    the configuration file. The input json file is formatted like

	{
		"username" : "<username>",
		"password" : "<password>",
		"userRole" : "admin"
	}

${0##*/} zone 192.168.0.1

	Add the Onezone IP to the configuration file.

${0##*/} provider Trieste 192.168.0.2

	Add the Oneprovider with name Trieste and IP 192.168.0.2 to the
	configuration file.

${0##*/} token admin

	Generate the access token for admin and save it into the
	configuration file.

Options:
  -h, --help       display this help and exit
  -g, --global     write to global ~/.odlbtconfig rather than ./config
EOF
  
    exit 0

}

# Funzione main
main() {

  # Variabili locali
  # Imposta i valori di default
  local command
  output=./config
  g=0
  
  while (( $# )); do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      -g|--global)
        g=1
        output=~/.odlbtconfig
        ;;
      -?*)
        echo "Unknown option $1" >&2
        exit 1
        ;;
      *)
        if [[ $1 == 'user' ]]; then
          command=$1
          input=$2
          shift
        elif [[ $1 == 'zone' ]]; then
          command=$1
          zoneIp=$2
          shift
        elif [[ $1 == 'provider' ]]; then
          command=$1
          providerName=$2
          providerIp=$3
          shift; shift
        elif [[ $1 == 'token' ]]; then
          command=$1
          user=$2
          shift
        else
          echo "Unknown command $1" >&2
        fi
		;;
    esac
    shift
  done

  if [[ $command == 'user' ]]; then
    # Usa questo if se vuoi verificare che l'input sia stato settato
    if [[ ! $input ]]; then
      echo "Missing input file" >&2
      exit 1
    fi
    configUser
  elif [[ $command == 'zone' ]]; then
    if [[ ! $zoneIp ]]; then
      echo "Missing input OneZone IP" >&2
      exit1
    fi
    configZone
  elif [[ $command == 'provider' ]]; then
    if [[ ! $providerIp ]]; then
      echo "Missing input OneProvider IP" >&2
      exit 1
    fi
    if [[ ! $providerName ]]; then
      echo "Missing input OneProvider Name" >&2
      exit 1
    fi
    configProvider
  elif [[ $command == 'token' ]]; then
    if [[ ! $user ]]; then
      echo "Missing user name" >&2
      exit 1
    fi
    configToken
  fi
  
}

# Usa questo if se il comando deve essere usato con degli input
if (( $# )); then
  main "$@"
else
  usage
fi
