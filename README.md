<h1 align="center">Running the Runner in Docker</h1>
<div align="center">
<a href="https://github.com/henrylam-250194/github-actions-runner-self-host/pulls"><img src="https://img.shields.io/github/issues-pr/henrylam-250194/github-actions-runner-self-host" alt="Pull Requests Badge"/></a>
<a href="https://github.com/henrylam-250194/github-actions-runner-self-host/issues"><img src="https://img.shields.io/github/issues/henrylam-250194/github-actions-runner-self-host" alt="Issues Badge"/></a>
<a href="https://github.com/henrylam-250194/github-actions-runner-self-host/graphs/contributors"><img alt="GitHub contributors" src="https://img.shields.io/github/contributors/henrylam-250194/github-actions-runner-self-host?color=2b9348"></a>
</div>

## Content
  - [Security Notes](#security-notes)
  - [Creating a Dockerfile](#creating-a-dockerfile)
  - [Installing Github Actions Runner](#installing-github-actions-runner)
  - [TODO](#fill-the-secret-informations)
  - [Deploy to Kubernetes](#deploy-to-kubernetes)

    
# Security notes :pencil:

  - Running in Docker needs high priviledges.
  - Would not recommend to use these on public repositories.
  - Would recommend to always run your CI systems in seperate Kubernetes clusters.

# Creating a Dockerfile

  - Installing Docker CLI For this to work we need a dockerfile and follow instructions to Install Docker. I would grab the content and create statements for dockerfile Now notice that we only install the docker CLI. This is because we want our running to be able to run docker commands , but the actual docker server runs elsewhere
  - This gives you flexibility to tighten security by running docker on the host itself and potentially run the container runtime in a non-root environment

# Installing Github Actions Runner

  - Next up we will need to install the GitHub actions runner in our dockerfile Now to give you a "behind the scenes" of how I usually build dockerfiles, I run a container to test my installs:
  ```yaml
  docker build . -t github-runner:latest
  ```
#Next steps:
  Now we can see docker is installed
  To see how a runner is installed, lets go to our repo | runner and click "New self-hosted runner"
  Try these steps in the container
  We will needfew dependencies
  We download the runner
  
# Fill the secret informations
Finally lets test the runner in docker
```yaml
docker run -it -e GITHUB_TOKEN="" -e OWNER=<> -e REPOSITORY=<> github-runner
```
$ If you are working on window please to install wsl and mount the docker deamon #/var/run/docker.shock into docker run command and expose the port if you want to test it locally.
```
docker run -v /var/run/docker.sock:/var/run/docker.sock -d -p 80:80 -it -e GITHUB_TOKEN=<> -e OWNER=<> -e REPO=<> github-runner
```

## Deploy to Kubernetes 

Load our github runner image so we need to push it to ECR/GCR or Docker Hub(anywhere you want for):
for now I am using local image.
```bash
kind load docker-image github-runner:latest --name githubactions
```

Create a kubernetes secret with our github details 

```bash
 kubectl -n github create secret generic github-secret \
   --from-literal OWNER=<> \
   --from-literal GREPOSITORY=<> \
   --from-literal GITHUB_TOKEN="<>" 
$ Remember run the docker sidecar to help run docker in docker. (see on k8s.yaml)
```
```bash
kubectl apply -f k8s.yaml
```
