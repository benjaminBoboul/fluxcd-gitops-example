#!/bin/bash
gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT:-gpg@demo.com}
Name-Real: ${KEY_NAME:-GPG-DEMO}
EOF
