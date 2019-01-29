#!/usr/bin/env bash

function usage {
  programName=$0
  echo 'description: post message to a Slack channel'
  echo "usage: $programName [-t 'sample title'] [-b 'message body'] [-c 'channel'] [-u 'slack url']"
  echo '    -t    message title'
  echo '    -b    message body'
  echo '    -u    Slack webhook url'
  exit 1
}

while getopts ":t:b:c:u:h" opt; do
  case ${opt} in
    t) msgTitle="$OPTARG"
      ;;
    u) slackUrl="$OPTARG"
      ;;
    b) msgBody="$OPTARG"
      ;;
    h) usage
      ;;
    \?) echo "Invalid option -$OPTARG" >&2
  esac
done

if [[ ! "${msgTitle}" || ! "${slackUrl}" || ! "${msgBody}" ]]; then
  echo 'all arguments are required'
  usage
fi

read -d '' payLoad << EOF
{
  "username": "$(hostname)",
  "attachments": [
    {
      "fallback": "${msgTitle}",
      "color": "error",
      "title": "${msgTitle}",
      "fields": [{
        "value": "${msgBody}",
        "short": false
      }]
    }
  ]
}
EOF


statusCode=$(curl \
              --write-out %{http_code} \
              --silent \
              --output /dev/null \
              -X POST \
              -H 'Content-type: application/json' \
              --data "${payLoad}" ${slackUrl})

echo ${statusCode}
