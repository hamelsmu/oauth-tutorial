# OAuth In Kubernetes

This section shows how to set up the [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview)](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview) on  [GKE](https://cloud.google.com/kubernetes-engine) to secure a website.  The motivation for this is that in many companies and enterprises, serving a site on Kubernetes may be the only option.

Unlike previous examples, the static site is served via its own web server rather than directly through the OAuth2 Proxy.  This web server's networking restricts access to be visible only internally within the Kubernetes cluster. The proxy forwards traffic to this web server.  This is a more general pattern in case you want to host other web applications that are not static sites (like dashboards).

:point_right: If you are unfamiliar with Kubernetes or OAuth, start with [Minimal Oauth](../local/README.md). :point_left:

## Pre-requisites

- A domain name.  If you don't have one, you [can buy one here](https://domains.google.com/)
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
OAUTH2_PROXY_SKIP_PROVIDER_BUTTON=true
```

You can generate the `OAUTH2_PROXY_COOKIE_SECRET` by running this:

```bash
python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
```

Finally, you can store these in your Kubernetes cluster:

```bash
kl create configmap oauth-env-file --from-env-file oauth.env
```

Note: you should use [secrets](https://kubernetes.io/docs/concepts/configuration/secret/) instead, but the goal is to keep things as minimal as possible.

### 4. Deploy your application

We can first deploy our web app with [k8s/deployment_1.yml](./k8s/deployment_1.yml) without any OAuth security.  You will need to edit the image name in the `Deployment` as well as the domains in `ManagedCertificate`.  After some time, you will be able to see your web page at your domain name with `https` properly working.

```
kubectl apply -f k8s/deployment_1.yml
```

Next, we can deploy the web app with an OAuth reverse proxy in front of it with [k8s/deployment_2.yml](./k8s/deployment_2.yml):

```
kubectl apply -f k8s/whitelist.yml # this is a whitelist of all the email addresses you want to allow to access your app.
kubectl apply -f k8s/deployment_2.yml
```

## Demo

See [https://hamel.page](https://hamel.page)

It will ask you to authenticate via GitHub, but will give you a 403 if your email is not in [k8s/whitelist.yml](./k8s/whitelist.yml).


