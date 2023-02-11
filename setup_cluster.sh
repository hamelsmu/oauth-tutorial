#setup container
docker build -t hamelsmu/hello-web --platform=linux/amd64 website/ && docker push hamelsmu/hello-web

gcloud container clusters create-auto oauth-demo \
    --region us-west1 \
    --project=kubeflow-dev 

gcloud container clusters get-credentials oauth-demo \
    --region us-west1 \
    --project=kubeflow-dev
