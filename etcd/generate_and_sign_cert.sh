HOST_NAME=$1
PRIVATE_IP=$2

JSON="{ \
  \"CN\": \"$HOST_NAME\", \
  \"hosts\": [ \
    \"$HOST_NAME\", \
    \"$HOST_NAME.local\", \
    \"127.0.0.1\", \
    \"$PRIVATE_IP\" \
  ], \
  \"key\": { \
    \"algo\": \"rsa\", \
    \"size\": 2048 \
  }, \
  \"names\": [ \
    { \
      \"C\": \"US\", \
      \"L\": \"Lyons\", \
      \"ST\": \"California\" \
    } \
  ] \
}"

echo JSON > ./$HOST_NAME.json
# cfssl gencert -ca=../certs/ca.pem -ca-key=../certs/ca-key.pem -config=
