#!/bin/sh

message=$(echo "$*" | sed 's/"/\"/g' | sed "s/'/\'/g" )
json="{\"text\": \"$message\"}"
url="https://hooks.slack.com/services/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"

curl -X POST -H 'Content-type: application/json' -d "$json" $url
