#!/bin/zsh
#USAGE: ./make_vocab.sh [train.knp]
#語彙を標準出力として出力

set -eu

if [ $# -ne 1 ]; then
  echo "Argument Error" >&2
  exit
fi

train_data_knp=$1
lv $train_data_knp | grep -v "^\*" | grep -v "^\+" | grep -v "^#" | awk '{print $3}' | sort | uniq
