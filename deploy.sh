# build images
docker build -t cielong/multi-container-client:latest -t cielong/multi-container-client:$GIT_SHA ./client
docker build -t cielong/multi-container-server:latest -t cielong/multi-container-server:$GIT_SHA ./server
docker build -t cielong/multi-container-worker:latest -t cielong/multi-container-worker:$GIT_SHA ./worker

# take those images and push them to docker hub
docker push cielong/multi-container-client:latest
docker push cielong/multi-container-server:latest
docker push cielong/multi-container-worker:latest
docker push cielong/multi-container-client:$GIT_SHA
docker push cielong/multi-container-server:$GIT_SHA
docker push cielong/multi-container-worker:$GIT_SHA

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=cielong/multi-container-server:$GIT_SHA
kubectl set image deployments/client-deployment client=cielong/multi-container-client:$GIT_SHA
kubectl set image deployments/worker-deployment worker=cielong/multi-container-worker:$GIT_SHA