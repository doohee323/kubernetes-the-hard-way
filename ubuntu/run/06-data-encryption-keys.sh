#!/bin/bash
set -e
#set -x

export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo " Generating the Data Encryption Config and Key "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

echo "====================================================================="
echo " The Encryption Config File"
echo "====================================================================="
rm -Rf encryption-config.yaml

cat > encryption-config.yaml <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ENCRYPTION_VAL
      - identity: {}
EOF
sed -i "s|ENCRYPTION_VAL|${ENCRYPTION_KEY}|g" encryption-config.yaml

echo "====================================================================="
echo " Distribute the Configuration Files"
echo "====================================================================="

for instance in doohee323-desktop; do
  echo $instance
  scp encryption-config.yaml ${instance}:~/
done
