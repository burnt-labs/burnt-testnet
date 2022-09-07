# burnt-testnet

Terraform and Kubernetes infrastructure suitable for the operation of testnets for cosmos-sdk based blockchains.

## Before you begin

We're going to need a few tools as we go along:

- [awscli](https://aws.amazon.com/cli/)
- [direnv](https://direnv.net/) 
- [docker](https://www.docker.com/)
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) 
- [kustomize](https://kustomize.io/) 
- [skaffold](https://skaffold.dev/)
- [terraform](https://www.terraform.io/)
- [tfenv](https://github.com/tfutils/tfenv) 
- [terragrunt](https://www.terraform.io/) 
- [tgenv](https://github.com/cunymatthieu/tgenv) 

If you are already familiar with most or all of these tools, please continue. If not, please do take the time to brush up on the specifics of 
the tools you're least familiar with.

## Not for Production Use

We have to say this up front - this codebase is in no way optimized, and shouldn't be run as-is in a production setting.

We're introducing sane defaults here, and building a reasonable base on which to start a discovery journey into what we've built at Burnt and
how we integrate into the larger Cosmos ecosystem. But there are many ways on which this codebase falls short of a 100% bulletproof,
production-ready setup.

With this obligatory disclaimer out of the way, let's begin!

## 1. Running a Local Node

In this section, we'll build some Docker images, and run a node locally using docker-compose.

### 1a. Build the base Docker image

We first want to build the base Docker image, which will contain the `burntd` binary and basic genesis node configuration.

Keep in mind that we're not optimizing the Docker image in this exercise; you're of course welcome to tune the artifact as you see fit for your own designs.

Also note that for the moment, the source Burnt `git` repository is private; you'll have to obtain an invite from the team, 
and then create a personal Github token to successfully perform the base image build.

Once you've obtained access to the repo and added your `GITHUB_API_TOKEN` to the provided `.envrc`:

```bash
$ cd ./docker/carbon-1/base-image
$ direnv allow
$ skaffold build
```

We're baking into the image a known-good configuration, contained in the `*.toml` files under `./config/...`. We'll 
use these files to populate volumes at runtime, and we can refer to this config if we make mistakes later on.

Great! We've built our base image.

### 1b. Run the Node locally for the first time

We're now ready to test if our Docker base image boots correctly.

```bash
cd ./docker/carbon-1
docker-compose up
```

You should see the `./docker/carbon-1/validator-node/data/...` bind-mount volume get populated with config files, 
along with various db and wasm cache folders.

At this point, you should see some testnet blocks syncing!

The Seed node we're using for peer discovery is:

```bash
21ed19017ea587f1c4c95f31248413ba9212b651@34.205.163.75:26656
```

And the known Persistent Peers we're using are:

```bash
80151cf5d1a69def2ff2d7c11321a6fa61ff9171@3.94.140.184:26656
f54c16895497f14038e11c9982155c21db77b875@52.200.208.139:26656
6e0ea208f4062e31026207b0ad52157c9286affd@3.218.177.240:26656
```

Fantastic! Our local setup is working as it should.

## 2. Setting up the AWS infrastructure with Terraform

We now need a home in the cloud to run our freshly-built Burnt node.

We'll be using a combination of `terraform` and `terragrunt` to deploy our AWS resources. The Terraform landscape, as you well know 
if you've worked with it before, is a free-for-all of many different ways to organize and/or generate configurations, and cut down on code duplication. 
We're fans of `terragrunt`, since we find it does a nice job of compartmentalizing and limiting the blast radius of specific infrastructure changes.

Other approaches are just as valid, and we support the age-old adage of There's More Than One Way To Do It (thanks, Larry!).

### 2a. Install Terraform and Terragrunt

As a convenience, we're going to pin our versions of Terraform and Terragrunt to specific versions, using `tfenv` and `tgenv`.

```bash
cd ./infrastructure/terraform
./tfenv.sh
```

We should now have these versions installed:

```bash
$ terraform version
Terraform v1.2.8

$ terragrunt version
[INFO] Getting version from tgenv-version-name
[INFO] TGENV_VERSION is 0.38.9
```

### 2b. Update the global Terragrunt configuration

Because we're using Terragrunt, we can consolidate values re-used by all our Terraform modules to a single location. 
In our case, the file we're interested in is: `./infrastructure/terraform/deploys/carbon-1/config.hcl`.

In this file, we will be setting our global AWS values, such as account number and IAM role to assume when using Terraform; we will
also be setting some label values which will be applied to every single cloud resource as a `tag`.

We also need to set the value of our `remote_state` S3 bucket, in `./infrastructure/terraform/deploys/terragrunt.hcl`.

Once all these values are to our liking, let's spawn some cloud resources!

### 2c. Create the VPC

We first need to create a custom VPC, which will contain all of our other cloud resources.

```bash
$ cd ./infrastructure/terraform/deploys/carbon-1/vpc
$ terragrunt apply
```

We'll end up with three public and three private subnets, their route tables, as well as a NAT gateway per availability zone.

### 2d. Create the KMS keys

We'll be using custom KMS keys to encrypt our data in transit and at rest. As such, we'll create a Storage key to encrypt our volumes,
and a separate Secrets key to encrypt our sensitive application values.

```bash
$ cd ./infrastructure/terraform/deploys/carbon-1/kms
$ terragrunt apply
```

A caveat here: if we attempt to allow KMS key usage to principals that don't exist yet, we'll end up with an error:

```bash
Error: error creating KMS Key: MalformedPolicyDocumentException: Policy contains a statement with one or more invalid principals.
```

A simple fix is to comment-out the offending principals until they exist, and the re-apply.

### 2e. Create the SecretsManager Secrets

Now that we have our custom KMS keys, we can create Secrets for our application.

```bash
$ cd ./infrastructure/terraform/deploys/carbon-1/secrets
$ terragrunt apply
```

In our example, we're creating two Secrets:

- `carbon-1/node/node-key`: should be set to the value of `./docker/carbon-1/node/data/config/node_key.json`
- `carbon-1/node/priv-validator-key`: should be set to the value of `./docker/carbon-1/node/data/config/priv_validator_key.json`

There are [several different ways](https://docs.tendermint.com/v0.34/tendermint-core/validators.html) of securing these two files; 
please use the method which makes the most sense for your particular use case.

### 2f. Create the ECR Docker registry

Our KMS keys also enable us to create an encrypted ECR Docker registry.

```bash
$ cd ./infrastructure/terraform/deploys/carbon-1/ecr
$ terragrunt apply
```

In our example, we're creating two registries:

- `base-image`: will contain the image we built in step 1a.
- `node`: will contain the configured node image we'll build in a minute.

### 2g. Create the EKS cluster

Here we go, this is the big one. We need an EKS cluster to run our Docker image.

Recall that to launch EC2 instances successfully, we'll need to allow KMS key usage to the EKS and EC2 services, as well as the AWS Autoscaling role.

```bash
$ cd ./infrastructure/terraform/deploys/carbon-1/eks/cluster
$ terragrunt apply
```

The EKS cluster we've just created has the following properties:

- A default managed node group
- Node volumes encrypted with our `storage` KMS key
- Remote shell access to EKS nodes via Systems Manager 
- `containerd` runtime
- `etcd` encrypted with our `secrets` KMS key
- `oidc` enabled
- `coredns` AWS add-on enabled
- `kube-proxy` AWS add-on enabled
- `vpc-cni` AWS add-on enabled

Let's update our `~/.kube/config` file, so we can connect to the cluster with `kubectl`:

```bash
$ aws eks udpate-kubeconfig --name $cluster-name --role $terraform-role-arn
$ kubectl cluster-info
```

Nice! Our AWS setup is almost complete.

### 2h. Additional EKS cluster configuration

Our vanilla EKS cluster is missing a few important parts; we need to install some additional Helm charts to the `kube-system` namespace with Terraform.

```bash
$ cd ./infrastructure/terraform/deploys/carbon-1/eks/helm
$ terragrunt apply
```

The parts we're adding are:

- `cluster-autoscaler`: controller that adds and removes nodes from the cluster as needed
- `ebs-csi`: driver which allows EKS to autoprovision volumes for our workloads
- `external-secrets`: proxy between AWS SecretsManager Secrets and Kubernetes secrets
- `lb-controller`: driver which links Kubernetes Service objects to AWS LoadBalancer resources.

We're using Terraform to install these charts to benefit from the proximity of our cluster's OIDC configuration and the 
target IAM Roles for Service Accounts we must create.

### 2i. Create Elastic IP's for our application

Finally, we are going to need some Elastic IP's for our application to be exposed to the Internet.

```bash
$ cd ./infrastructure/terraform/deploys/carbon-1/ec2/eips
$ terragrunt apply
```

We'll associate these IP's to the LoadBalancers that we'll create when deploying the app to EKS.

Success! We're done with Terraform for now.

## 3. Build and deploy the Docker images to ECR

It's time to build our Docker images and deploy them to ECR, to make them available to EKS.

Before you run the commands below, be sure to update the Docker image tags in the `skaffold.yaml` to your ECR registries. 
You'll also need to set the `build.local.push` boolean to `true`.

```bash
$ cd ./docker/carbon-1/base-image
$ skaffold build
$ cd ./docker/carbon-1/node
$ skaffold build
```

Excellent, we're almost done.

## 3. Deploying the Node to EKS

With our AWS infrastructure in place, and our container images built, we can configure and deploy our application.

### 3a. Create the Kubernetes Namespace and StorageClass

We'll need a Namespace to deploy our application to, as well as a StorageClass for our volumes.

Note that for the EBS CSI driver to encrypt our volumes with our Storage KMS key, we must:

- Add the KMS key ID to the StorageClass manifest, in `parameters.kmsKeyId`
- Allow KMS key usage to the `external-secrets` IAM Role we created in step 2h. 

```bash
$ cd ./infrastructure/manifests/carbon-1
$ skaffold deploy
```

### 3b. Deploy the Node

To successfully deploy the Node, we need to configure some manifests:

- We must annotate the `ServiceAccount` with the IAM role we created in `external-secrets` in step 2h. This will allow it to read from AWS Secrets Manager.
- We must annotate the `Service` with the correct Elastic IP allocations and Subnet ID's to apply to the LoadBalancer
- We must set the correct Node Docker image `url:version` in the `StatefulSet` container spec

```bash
$ cd ./infrastructure/manifests/carbon-1/node
$ skaffold deploy
```

At a high level, our deployment will:

- Create and mount Kubernetes `Secrets` from `ExternalSecrets`
- Create and mount an encrypted EBS `Volume`
- Create and mount a `ConfigMap` with our application's config values 
- Launch a `StatefulSet` with our Docker image
- Expose the Tendermint `p2p` port for peers to connect to us

A few troubleshooting tips if you don't succeed on your first try:

- Tail the event log in the namespace: `kubectl -n carbon-1 get events --sort-by='.lastTimestamp' -w`
- Check your ExternalSecrets resources:
  - `kubectl describe secretstore` 
  - `kubectl describe externalsecret` 
- Check your persistent volumes:
  - `kubectl describe pvc`
  - `kubectl describe pv`

Assuming you've successfully launched the StatefulSet, let's tail the container logs:

```bash
$ kubectl logs -f node-0
```

Congratulations! We've launched a Burnt full node, and are now catching up to the chain HEAD.
