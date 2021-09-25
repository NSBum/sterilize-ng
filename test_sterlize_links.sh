#!/bin/bash

function domain() {
   echo $1 | awk -F[/:] '{print $4}' \
           | sed -E 's/^(.*\.)?([^\.]*\.[^\.\?]*).*/\2/g'
}

# path to link sterilizer
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
STERLIZE_PATH="$SCRIPTPATH/sterilize-ng.sh"
CSVPATH="$SCRIPTPATH/test_links_sterilize.csv"
echo "Checking links at $CSVPATH"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# process test linls
while IFS="," read -r actual expected
do
   actual=$(echo $actual | sed -E 's/"//g')
   expected=$(echo $expected | tr -d '"')
   STERILIZE=$(echo $actual | $STERLIZE_PATH)
   exp_len=${#expected}
   ster_len=${#STERILIZE}

   if [[ "$expected"  == "$STERILIZE" ]]; then
      echo "${GREEN}correct:${RESET} $(domain $actual) -> $(domain $STERILIZE)"
   else
      echo "${RED}incorrect:${RESET} $(domain $actual) -> $STERILIZE -> ${RED}$exp_len vs. $ster_len${RESET}"
   fi
done < <(tail -n +2  $CSVPATH)