# fluxcd-gitops-example
This repository explain how to step by step setup a gitops workflow using `flux` and `ksops` for secrets management.
We're going to use `kustomize` to write our manifests in order to deploy a simple nginx server with a encrypted secret.

# :octocat: Requirements

- Kubernetes cluter (in this example we'll use `minikube`): https://minikube.sigs.k8s.io/docs/
- `kubectl` utility: https://kubernetes.io/docs/tasks/tools/
- `sops` utility: https://github.com/mozilla/sops 

Once required tools are installed, we can create our cluster using the following commands:
```bash
minikube start
kubectl cluster-info
```

When creating, `minikube` will set required settings in $KUBECONFIG allowing you to interact with `kubectl`.

## Install flux

```bash
curl -s https://toolkit.fluxcd.io/install.sh | sudo bash
flux check --pre
```

In our case, since we're using flux in local, we'll install flux by typing: 

```bash
flux install
```

### Register our repository as a Git source

Here we'll create a git source named `test`:

```bash
flux create source git test --url=https://gitbub.com/benjaminBoboul/fluxcd-gitops-example --branch=main

# check the source:
flux get sources git
#NAME	READY	MESSAGE                                                        	REVISION                                     	SUSPENDED
#test	True 	Fetched revision: main/9b11bf3c6731792f79bb057490bf75114f9ee462	main/9b11bf3c6731792f79bb057490bf75114f9ee462	False
```

### Create a kustomize deployment

Define a kustomize deployment called `testkustomize`

```bash
flux create kustomization testkustomize --source=GitRepository/test --path="./deployment/environments/production" --prune=true --interval=10m

# check kustomization
flux get kustomizations
#NAME 	READY	MESSAGE                                                        	REVISION                                     	SUSPENDED
#testkustomize	True 	Applied revision: main/9b11bf3c6731792f79bb057490bf75114f9ee462	main/9b11bf3c6731792f79bb057490bf75114f9ee462	False
```

## Generate GPG key for SOPS encryption

We need to disable gpg key password with the `%no-protection` so flux would be able to decrypt secrets in our cluster.

```bash
gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF
```

Export public & private key pair to kubernetes secrets :
```bash
gpg --export-secret-keys --armor <KEI_ID> | kubectl create secret generic sops-gpg --namespace=flux-system --from-file=sops.asc=/dev/stdin
```

