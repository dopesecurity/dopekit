# dopekit

This is the template for a new cloud service on AWS. After bootstrapping, you will have a complete production-grade repo for a basic service (hello world lambda).


## How it works
We want all our cloud services to be consistent and easy to work on. The basic idea of this template is to give you a ready-to-go repository, where you can use `make` to easily perform all relevant tasks (build packages, run tests, deploy, etc.), while having a standard deployment pipeline that is well-tested and understood. We also include all the best practices and goodies we like to use, such as pre-commit, a PR template, etc.

Specifically, this template contains:
- python source code and unit tests for hello world lambda
- terraform for IaC deployment to AWS
- component tests targeting deployed service on AWS
- Circle CI Pipeline to test and deploy service all the way to production
- Docker image for running CI pipeline
- Makefile for running all service commands
- pre-commit, github templates, and other goodies

## Set up the repo
 After creating a new repo, search for `FIXME`s and replace them accordingly. The main things to replace:
 - dev and prod slack channel IDs for notifications (`dynamic_config.yml`)
 - Docker repository for the CI image (`dynamic_config.yml`)
 - Service name (`variables.tf`)
 - S3 bucket, DynamoDB table, and service prefix for terraform remote backend for dev and prod (`dev/prod-backend.tfvars`)


## CI/CD
- We use CircleCI for our pipelines. If you use something else, you'll have to build your own pipeline (we'd love to see a P/R for that). It should be relatively straightforward, since `make` does the bulk of the heavy lifting. The CI pipeline mainly chains `make` calls together.

## Contributing
We welcome contributions to improve this template, in the form of Pull Requests or Issues.

## What's next

When you're finished setting up your repo, you can use the text below as a starting point for its README

# service name

Briefly describe service here.
Example: The cloud-template provides a starting point repository for new cloud services.

# How to build & deploy
## Pre-requisites

* All operations are done with make. It should already be installed. Otherwise: `brew install make`
* Deployment is managed via terraform: `brew install terraform` (protip: install with `tfenv`)
* We use pre-commit hooks. If you don't pre-commit installed, it can be installed with pip (`pip install pre-commit`)
  * Once you have pre-commit installed, run the following command to install the repository hooks: `pre-commit install --install-hooks`
* Helper scripts are written in Python and managed with Poetry:
  * `brew install python@3.y` (protip: install with `pyenv` instead)
  * `pip install poetry` (protip: install with `pipx` instead)

## How to build
* To setup dependencies: `make install`
* To run unit tests: `make unit-tests`
* To build lambda packages: `make build`

## How to deploy

* To plan deployment: `make plan`
* To deploy infrastructure: `make deploy`
* To run component-tests: `make component-tests`
* To destroy deployed infrastructure: `make destroy`

You can call `make help` to see all available targets.

# Important Notes

Major things, if any, that anyone checking out the repo should know about.
Example: when making changes to the template, please create a quick example service to make sure everything is still working out of the box.
