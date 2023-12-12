#!/bin/sh
registration_url="https://api.github.com/repos/$OWNER/$REPO/actions/runners/registration-token" # need to be change to ORG runner url it you want to change to ORG self runner
echo "Requesting registration URL at '$registration_url'"

# API call to generate the registration token for a GitHub repository runner

response=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $GITHUB_TOKEN" $registration_url)

export RUNNER_TOKEN=$(echo $response | jq .token --raw-output)
# # Extract the token from the response

echo "Runner registration token: $RUNNER_TOKEN"

# cd /home/runner/actions-runner
./config.sh --url https://github.com/$OWNER/$REPO --token $RUNNER_TOKEN --name $(hostname)

trap 'remove; exit 130' INT
trap 'remove; exit 143' TERM

./run.sh "$*" &

wait $!
