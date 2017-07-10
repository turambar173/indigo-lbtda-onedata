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
Usage: ${0##*/} [-h] <command> [<args>]

The odlbt commands are:
    config     Configure the odlbt package
    metadata   Add metadata to files uploaded in OneData
    space      Create and manage OneData spaces
    user       Create and manage OneData users

See 'odlbt command --help' to read about a specific command.

Options:
  -h, --help       display this help and exit
EOF
  
    exit 0

}

# Funzione main
main() {

  # Variabili locali
  # Imposta i valori di default
  local output input
  local a=0
  
  while (( $# )); do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      config)
        shift
        odlbt-config $@
        break
        ;;
      user)
        shift
        odlbt-user $@
        break
        ;;
      space)
        shift
        odlbt-space $@
        break
        ;;
      metadata)
        shift
        odlbt-metadata $@
        break
        ;;
      *)
        echo "Unknown option $1" >&2
        exit 1
        ;;
    esac
    shift
  done
 
  exit 0
     
}

# Usa questo if se il comando deve essere usato con degli input
if (( $# )); then
  main "$@"
else
  usage
fi
