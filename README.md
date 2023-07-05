# docker-build-publish-example

Using Github Actions to build a Docker image and publish it to image repositories.

## Contents

- [aws/oidc-idp](./aws/oidc-idp/) - AWS CloudFormation template to create a Github OIDC Identity Provider for Github
- [aws/iam-ecr](./aws/iam-ecr/) - AWS CloudFormation template to create an IAM Role that Github Actions can assume
- [Dockerfile](./Dockerfile) - Trivial Dockerfile defining an example image
- [.github/workflows/build-and-push.yml](.github/workflows/build-and-push.yml) - Github Actions workflow specification to build and push a Docker image to multiple Docker image repositories

## How To Use this Repo

### 1 - Fork
Fork this repo to your Github user/organization. Note the repo name (e.g., `mygithubuser/docker-build-publish-example`) since you will need it later.

### 2 - Github OIDC Provider in AWS
*If you have a provider named `token.actions.githubusercontent.com` in https://us-east-1.console.aws.amazon.com/iamv2/home#/identity_providers, then you can skip this step.* 

If you do not already have a Github OIDC identity provider configured in your AWS account, then use [aws/oidc-idp/template.yml](./aws/oidc-idp/template.yml) CloudFormation template to create the provider in AWS. 

### 3 - IAM Role and ECR Repo in AWS

Use the [aws/iam-ecr/template.yml](./aws/iam-ecr/template.yml) CloudFormation template to create an IAM role and an ECR repo.

You will need to provide the name of your forked Github repo (e.g, `mygithubuser/docker-build-publish-example`) as the value of `GithubRepoListParam` when you create the CloudFormation stack.

Note the ARN of the IAM role created. You will need it later.

### 4 - Docker Hub Repo

In your `hub.docker.com` account, create a new repostory named `docker-build-publish-example`.

### 5 - Github Actions Secrets and Variables

In your forked repo, create the following Github Actions Secrets and Variables:

| Type | Name | Description | Example Value |
| ---- | ---- | ---- | ---- |
| secret | AWS_ECR_ACCOUNT     | AWS Account ID where you deployed [aws/iam-ecr/template.yml](./aws/iam-ecr/template.yml) | 123456789012 |
| secret | AWS_ROLE_ARN        | ARN of the IAM role created by [aws/iam-ecr/template.yml](./aws/iam-ecr/template.yml) | arn:aws:iam::123456789012:role/github-ecr-publish-dev-role-Role-GEWKXI03S0JB |
| secret | DOCKER_HUB_PASSWORD | User name for `hub.docker.com` | mydockerhubuser |
| secret | DOCKER_HUB_USERNAME | Password for `hub.docker.com` | |
| variable | ACTIONS_STEP_DEBUG | Optional configuration to see detailed debugging of the Github Actions step execution | `true` |
| variable | AWS_ECR_IMAGE_NAME | Name of the ECR repo created by [aws/iam-ecr/template.yml](./aws/iam-ecr/template.yml) | `docker-build-publish-example` |
| variable | AWS_ECR_REGION | AWS region of your ECR repo | `us-east-1` |
| variable | DOCKER_HUB_IMAGE_NAME | Name of the Docker Hub repo you created | `docker-build-publish-example` | 

### 6 - Enable Github Actions Workflows

By default, Github Actions workflows are not enabled on forked repos. You need to enable them, so navigate to your forked repo and click on the **Actions** tab. Enable them. See https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#enabling-workflows-for-forks-of-private-repositories.

### 6 - Trigger a New Release

Trigger a new release, build, and push by creating and pushing a new tag with format:
```
v<MAJOR_VERSION>.<MINOR_VERSION>.<PATCH_NUMBER>
```
For example, `v1.0.0`. 

You can use the following `git` commands to create a push a tag:

```
git tag -a v1.0.0 -m v1.0.0
git push origin v1.0.0
```

### 7 - Watch

Watch Github Actions for the results of your workflow run. Upon success you should see an image pushed to the following locations:

- The packages section of your forked Github repo. 
    - E.g., `https://github.com/mygithubuser/ct-docker-build-publish-example/pkgs/container/docker-build-publish-example`
- Your Docker Hub repository. 
    - E.g., 
`https://hub.docker.com/repository/docker/mydockerhubuser/docker-build-publish-example/`
- Your AWS ECR repository. 
    - E.g., `https://us-east-1.console.aws.amazon.com/ecr/repositories/private/123456789012/docker-build-publish-example?region=us-east-1`
