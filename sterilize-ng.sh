#!/bin/bash

# sterilize-ng
#
# Sterlize URLs of most tracking information
#
# Change log
#
# 2021-09-24 v0.50   Functional version
# 2021-09-25 v0.60   Add Bing link extraction

ORIGINAL_URL="https://support.apple.com/en-ca/billing?cid=email_receipt"

read ORIGINAL_URL

# Unwrap link (following redirects)
# using proxychains-ng for privacy
# if available
function unwrap-ng() {
   if [[ -d /usr/local/Cellar/proxychains-ng ]]; then
      RES=$(proxychains4 -q curl -sLI $1)
   else
      RES=$(curl -sLI $1)
   fi
   <<<"$RES" grep -i Location \
   | tail -n 1 \
   | sed -E 's/location:.*(http.*)/\1/g' \
   | sed -E 's/(.*)./\1/g'
}

function unwrap_shortened() {
   link=$1
   declare -a shorteners=(
      "^http[s]?://bit.ly.*$"
      "^http[s]?://tinyurl.com.*$" 
      "^http[s]?://ow.ly.*$"
      "^http[s]?://goo.gl.*$"
      "^http[s]?://t.co.*$"
      "http[s]?://amzn.to.*$")
   for i in "${shorteners[@]}"
   do
      if [[ $link =~ $i ]]; then
        echo $(unwrap-ng $link)
        return
     fi
  done
  echo $link
}

# Decode URL-encoded link
function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# remove urchin tracking
function urchin_kill() {
   if [ "$#" -gt 0 ]; then
      temp_url=$1
   else
      read temp_url
   fi
   echo $temp_url | sed -E 's/(utm_[^_=]*=[^=&]*)//g'
}

# remove Facebook-specific tracking
function fb_kill() {
   if [ "$#" -gt 0 ]; then
      temp_url=$1
   else
      read temp_url
   fi
   echo $temp_url | sed -E 's/(fbclid=[^=&]*)//g' \
   | sed -E 's/(h=[^=&]*)//g' \
   | sed -E 's/(__tn__=[^=&]*)//g' \
   | sed -E 's/(c\[[0-9]*\]=[^=&]*)//g' \
   | sed -E 's/(r=[^=&]*)//g'
}  

function amazon_kill() {
   declare -a amzparams=(
      "ref" "ie" "creative" "creativeASIN", "linkCode"
      "tag" "linkId" )
   for i in "${amzparams[@]}"
   do
      URL=$(echo $URL | sed -E "s/($i=[^&=\?]*)//g")
   done
   # keep our target URL
}

# tidy up after removing tracking
function tidy_url() {
   if [ "$#" -gt 0 ]; then
      temp_url=$1
   else
      read temp_url
   fi
   echo $temp_url | sed -E 's/([^&]*)&*/\1/g' \
   | sed -E 's/^(.*)\?$/\1/g'
}

# Decode and remove Google UTM params
URL=$(urldecode $ORIGINAL_URL | urchin_kill)
URL=$(unwrap_shortened $URL)
# echo $URL

# liberate link from Facebook
if [[ $URL =~ ^.*facebook.com/l.php.*$ ]]; then
   URL=$(sed -E 's/.*u=(.*)/\1/g' <<< "$URL")
fi

# kill any Facebook tracking params
URL=$(echo $URL | fb_kill)

# sterilize certain Bing links
# 
# Regular Bing links don't have embedded tracking identifiers
# but advertising/shopping links do. So we will unwrap and 
# clean up all the tracking garbage

if [[ $URL =~ ^https://www.bing.com/acl.*$ ]]; then
   # this is a Bing advertising link
   # unwrap it
   BINGEXP=$(unwrap-ng $URL)
   if [[ $BINGEXP =~ ^.*doubleclick.*$ ]]; then
      # this is a doubleclick ad of some sort
      T=$(echo $BINGEXP | sed -E 's/^.*=(http[^\?]*).*$/\1/g')
      URL=$T
   else
      if [[ $BINGEXP =~ ^.*ebay.*$ ]]; then
         URL=$(echo $BINGEXP | sed -E 's/^(http[^\?]*)(.*)$/\1/g')
      else
         URL=$(echo $BINGEXP | sed -E 's/^(http[^\?]*)(.*)$/\1/g')
      fi
   fi
fi

# kill any Google tracking params
if [[ $URL =~ ^http[s]?://www.google.com.*$ ]]; then
   declare -a gparams=(
      "src" "q" "source" "sa" "rct" "r"
      "cd" "cad" "uact" "ved" "usg" "client"
      "sclient" "sourceid" "resnum" "as_q" "oi"
      "pq" "aq" "oq" "ref_src" "esrc")
   for i in "${gparams[@]}"
   do
      URL=$(echo $URL | sed -E "s/($i=[^&=\?]*)//g")
   done
   # keep our target URL
   URL=$(echo $URL | sed -E 's/.*url=(.*)$/\1/g')
fi

# kill any Amazon tracking params
if [[ $URL =~ ^http[s]?://www.amazon.*$ ]]; then
   declare -a amzparams=(
      "ref" "ie" "creative" "creativeASIN" "linkCode"
      "tag" "linkId" "camp" "keywords" "language"
      "ref_" "qid")
   for i in "${amzparams[@]}"
   do
      URL=$(echo $URL | sed -E "s/($i=[^&=\?]*)//g")
   done
   # some Amazon links have a flag s without
   # any value
   # echo $URL
   URL=$(echo $URL | sed -E 's/(.*)(&s&)/\1/g')
fi

# unwrap shortened in case it was
# hidden in FB link
URL=$(unwrap_shortened $URL)

# remove miscellaneous tracking params (IG, etc.)
declare -a mparams=(
   "igshid" "icid" "mc_eid" "ICID"
   "_hsenc" "_hsmi" "vero_conv" "vero_id"
   "sr_share" "cid"
   )
for i in "${mparams[@]}"
do
   URL=$(echo $URL | sed -E "s/($i=[^&=\?]*)//g")
done

# final clean
echo $URL | tidy_url


