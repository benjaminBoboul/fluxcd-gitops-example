#!/bin/bash

gpg --export-secret-keys --armor 6517DCF84AC5E723E94D424E8CE35D1F71F279B9 | kubectl create secret generic sops-gpg --namespace=flux-system --from-file=sops.asc=/dev/stdin

