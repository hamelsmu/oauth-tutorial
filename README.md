# Secure Your Static Sites Behind Oauth

We will use [Oauth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview) to secure a static site.  This is a minimal example.


## Pre-requisites

- A domain name.  If you don't have one you [can buy one here](https://domains.google.com/)
- A google cloud account
- Deploy a hello-world Kubernetes cluster with [these instructions](https://cloud.google.com/kubernetes-engine/docs/deploy-app-cluster)

## Steps

You can see the commands I used in [setup_k8s.sh](./setup_k8s.sh)

### 1. Build Docker Container

```bash
DOCKER_NM=<your docker repo/img name> # ex: hamelsmu/hello-web
docker build -t $DOCKER_NM --platform=linux/amd64 . && docker push $DOCKER_NM
```

### 2. Create Google Kubernetes Cluster & Static IP

```bash
gcloud container clusters create-auto oauth-demo \
    --region us-west1 \
    --project=<your-project-name>

gcloud compute addresses create oauth-ip-address --global
```

### 3. Setup GitHub OAuth and configuration variables 

Create an [OAuth App](https://github.com/settings/applications/new), and fill out the following fields:

- **Application Name:** Any name you want, I called it `k8s-oauth`
- **Homepage URL:** this is the url of the website `https://hamel.page`
- **Application Description:** you can skip this
- **Authorization callback URL:** your url with the path `/oauth2/callback` for example, I put `https://hamel.page/oauth2/callback`.

Take note of the `ClientID` and `Client secret`, which you will use below.

Create a file named `oauth.env` with the following contents:

```text
OAUTH_CLIENT_ID=your-client-id # from GitHub
OAUTH_CLIENT_SECRET=your-client-secret # from GitHub
OAUTH2_PROXY_COOKIE_SECRET=your-cookie-secret # you generate this locally, see below.
```

You can generate the `OAUTH2_PROXY_COOKIE_SECRET` by running this:

```bash
python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
```

Finally, you can store these in your Kubernetes cluster:

```bash
kl create configmap oauth-env-file --from-env-file oauth.env
```

Note: you should actually use [secrets](https://kubernetes.io/docs/concepts/configuration/secret/), but the goal is to keep things as minimal as possible.

### 4. Deploy your application

We can first deploy our web app with [k8s/deployment_1.yml](./k8s/deployment_1.yml) without any OAuth security.  You will need to edit the image name in the `Deployment` as well as the domains in `ManagedCertificate`.  After some time, you will be able to see your web page at your domain name with https properly working.

```
kubectl apply -f k8s/deployment_1.yml
```

Next, we can deploy the web app with an OAuth reverse proxy in front of it with [k8s/deployment_2.yml](./k8s/deployment_2.yml):

```
kubectl apply -f k8s/deployment_2.yml
```
