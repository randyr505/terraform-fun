#!/bin/sh

message=$(echo "$*" | sed 's/"/\"/g' | sed "s/'/\'/g" )
json="{\"text\": \"$message\"}"
url="https://hooks.slack.com/services/AAA/AAA/AAA"

curl -X POST -H 'Content-type: application/json' -d "$json" $url
