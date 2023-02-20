#setup container
docker build -t hamelsmu/hello-web --platform=linux/amd64 . && docker push hamelsmu/hello-web

gcloud container clusters create-auto oauth-demo \
    --region us-west1 \
    --project=kubeflow-dev 

# Create a static IP address
gcloud compute addresses create oauth-ip-address --global

# Get the IP address

gcloud compute addresses describe oauth-ip-address --global
#  34.110.194.239
# Setup your DNS with an A record for your domain pointing to this IP address
# This IP will be referenced by the ingress resource by name "oauth-ip-address"

### Create a file named oauth.env with the following contents
# generate the cookie secret like this:
# python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'

# OAUTH_CLIENT_ID=your-client-id
# OAUTH_CLIENT_SECRET=your-client-secret
# OAUTH2_PROXY_COOKIE_SECRET=your-cookie-secret

# Create a configmap from the oauth.env file
kl create configmap oauth-env-file --from-env-file oauth.env
