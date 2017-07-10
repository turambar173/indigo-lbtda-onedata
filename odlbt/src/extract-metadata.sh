#!/bin/bash

# Definisci il PREFIX
PREFIX=$(dirname $(dirname $(realpath $0)))

${PREFIX}/lib/extract-header.py $@
