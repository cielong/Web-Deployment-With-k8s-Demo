# Web Deployment With K8s Example
A multi-container web application development example using Travis CI and K8s. This is a course project follows closely [Docker and Kubernetes: The Complete Guide](https://www.udemy.com/docker-and-kubernetes-the-complete-guide/) and it is intended to imitate production development with CI/CD using an over-complex multi-containers Fibnacci number calculator web application.  

<p align="center">
  <img src="https://imgur.com/rerbh34.png"/>
  <br/>
</p> 

## Getting Started
### File Description
#### Web Application Source Code

* client/
* server/
* worker/

As indicated by the folder name, each service is under its own directory and will be hosted in one/multiple separate docker containers with its own Dockerfile.  

**Key Points**
1. To clearly distinguish development and production environments, separarted Dockerfiles (*Dockerfile.dev vs. Dockerfile*) have been created.

#### Travis CI and GCP Related

* .travis.yml
* deploy.sh

CI/CD workflow has been created using Travis CI. In order to deploy on Google Cloud Platform, it is required to manually config google cloud sdk through Travis CI environment because Travis CI does not provide its own handlers.  

**Key Points**
1. To force k8s updates deployments' images whenever master branch's codebases change, we tag the built image with the current git hash.  
2. To encrypt and safely upload GCP credential files into Travis CI, we need Travis CI CLI. In order to work around dependency issues on different os platforms, using docker ruby image to accomplish this stage greatly save times.

#### K8s

* k8s/

K8s is used to manage each service, with each service been managed by separate config file.  

<p align="center">
  <img src="https://i.imgur.com/wsYGHlx.png"/>
  <br/>
</p>  

In the above architecture diagram, every component is hosted as a deployment object in K8s while omiting necessary Cluster IP Service object. The function of each object is as follows:

| Component             | Function                                                                              |
|:--------------------- |:------------------------------------------------------------------------------------- |
| Nginx Ingress         | K8s object takes care of incomming requests                                           |
| Fib Calculator Client | Frontend pages that show Fibnacci numbers and their indices                           |
| Fib Calculator Server | Backend handles user input requests: distribute workloads, retrieve stored results    |
| Fib Calculator Worker | Calculate Fibnacci number if the result has not been calculated using recursive algos |
| PostgreSQL            | Store calculated Fibnacci numbers' indices                                            |
| Redis                 | Cache calculated Fibnacci numbers and their indices                                   |

**Key Points**
1. To avoid manually written password in a config file, a Secret object is created through k8s CLI imperative command. 

### Environment Setup
#### Prerequisite
To test the whole web services locally, the following requirements must be satisfied first:
1. Docker, Kubernetes, Kubernetes CLI (kubectl) has been installed on personal computer. 
2. A valid Docker Hub account has been set up.

To deploy on GCP, along with the above, the following requirements must be satisfied first:
1. A valid Github account.
2. A valid credit card and Google account.

#### First of All
Open terminal and clone the repo using the following,   

```sh
git clone https://github.com/cielong/Web-Deployment-With-k8s-Demo.git
```

#### Test on your local environment
1. Build images from given web application source code and push them to Docker Hub,
```sh
# Image name check each service's deployment config file, you should done this for 
# client, server and worker service
docker build -t <image_name>:<image_tag> <service_path_in_relative>
docker push <image_name>:<image_tag>
```
2. Install [Nginx-Ingress](https://github.com/kubernetes/ingress-nginx), please refer to the [Deployment section](https://kubernetes.github.io/ingress-nginx/deploy/).  
3. Create pgpassword secret for logging in PostgreSQL,  
```sh
kubectl create secret generic <secret_name> --from-literal PGPASSWORD=<any_password_you_want_to_use>
```
4. Apply k8s config files using kubectl,
```sh
kubectl apply -f k8s
```
5. Open browser and verify web applications,
```
<ip_address>
```

#### Deploy on GCP
1. Create a Github repo for this project.
2. Set up CI/CD with [Travis CI](https://travis-ci.org/),  

    1. Log in with your Github account and select the repo you just created to be watched by Travis CI.
    2. Log in your Docker Hub and generate Docker Hub token and add them in the setting section as environment.
  
3. Create cluster using GCP Kubernetes Engine

    1. Create service account and download the json files with access token.
    2. Using Travis CI CLI to encrypt the json files using docker,
    ```sh
    docker run -it -v $(pwd):/app ruby:2.3 sh
    # In the docker terminal
    cd /app
    gem install travis
    travis login
    # Copy the json file into the volumed directory
    travis encrypt-file <json_file_name> -r <repo_name_we_want_to_tied_the_secret_with>
    # Copy the result decrypt instruction command from the output of last command and paste it into the very first stage of .travis.ci before_install section
    # Delete the original secret file while keep the encrypted file
    ```
    3. Open the CLI in GDP and creat pgpassword secret as in local envrionment,
    ```sh
    kubectl create secret generic <secret_name> --from-literal PGPASSWORD=<any_password_you_want_to_use>
    ```
  
4. Push your code into github. If everything works fine in Travis CI, check the GDP to goto the ip address of nginx ingress service.

