#!/bin/bash

date_now=$(date +'%Y%m%d%H%M%S')

receiver_email_file="/app/email.txt"
receiver_email=$(cat "$receiver_email_file")

api=$(curl -X POST -H "Content-Type: application/json" -d '{"name": "My_API_Token_'"$date_now"'","role": "Admin", "secondsToLive": 3600}' -u admin:admin http://$pod_ip:3000/api/auth/keys)

token=$(echo "$api" | jq -r '.key')

grafana-reporter -cmd_enable=1  -ip $pod_ip:3000 -cmd_dashboard $dashboard_uid -cmd_ts from=now-1M -cmd_o $out_file -cmd_apiKey $token

echo $mail_body | mail -s $mail_subject -A $out_file $receiver_email
