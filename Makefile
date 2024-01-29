include Makefile.env

TF_VAR_ARGS= -var-file=tfvars/${AWS_ENV}.tfvars -var="aws_region=${AWS_REGION}" \
	-var="stack_name=${TF_STACK_NAME}" -var "deployer_id=${DEPLOYER_ID}"

# protect from accidental commands against protected stacks
ifdef PROTECTED_STACK
    # check if `circle` is a substring of DEPLOYER_ID. Error if it isn't
	ifeq (,$(findstring true,$(CIRCLECI)))
$(error Only CI is allowed to operate on ${TF_STACK_NAME})
	endif
endif

#------ Main Targets ------#

help: ## Show this help
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "}; \
	       /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: display-env
display-env: ## Print important env variables
	@echo "AWS_REGION: ${AWS_REGION} ($(origin AWS_REGION))"
	@echo "AWS_ENV: ${AWS_ENV} ($(origin AWS_ENV))"
	@echo "DEPLOYER_ID: ${DEPLOYER_ID} ($(origin DEPLOYER_ID))"
	@echo "TF_STACK_NAME: ${TF_STACK_NAME} ($(origin TF_STACK_NAME))"
	@echo "TF_WORKSPACE_NAME: ${TF_WORKSPACE_NAME} ($(origin TF_WORKSPACE_NAME))"
	@echo "PROTECTED_STACK: ${PROTECTED_STACK} ($(origin PROTECTED_STACK))"

.PHONY: clean
clean: ## Delete dependencies and other files
	rm -rf terraform/.terraform/
	rm -rf build/*
	find . -type d -name "__pycache__" -exec rm -rfv {} + > /dev/null
	find . -type d -name ".venv" -exec rm -rfv {} + > /dev/null
	find . -type d -name ".pytest_cache" -exec rm -rfv {} + > /dev/null
	find . -type f -name ".coverage" -exec rm -rfv {} + > /dev/null
	find . -type f -name "coverage.xml" -exec rm -rfv {} + > /dev/null
	find . -type d -name "htmlcov" -exec rm -rfv {} + > /dev/null
	find . -type d -name "build" -exec rm -rfv {} + > /dev/null
	find . -type d -name ".ruff_cache" -exec rm -rfv {} + > /dev/null

.PHONY: install
install: ## Install all dependencies for local development
	poetry install --no-ansi --no-root

.PHONY: build
build: ## Prepare packages for deployment
	@mkdir -p build
	$(call package_lambda,example_lambda)

.PHONY: unit-tests
unit-tests: ## Run all unit tests
	$(call run_unit_tests,example_lambda)

.PHONY: update-deps
update-deps: ## Update all dependencies
	$(call update_python_deps,.)
	$(call update_python_deps,src/example_lambda)

.PHONY: plan
plan: terraform/.terraform ## Plan infrastructure deployment
	$(info Workspace: ${TF_WORKSPACE_NAME})
	cd terraform && \
	(terraform workspace select ${TF_WORKSPACE_NAME} || terraform workspace new ${TF_WORKSPACE_NAME}) && \
	terraform plan -out tf.plan ${TF_VAR_ARGS}

.PHONY: deploy
deploy: ## Deploy planned infrastructure
	$(info Workspace: ${TF_WORKSPACE_NAME})
	@cd terraform && \
	terraform workspace select ${TF_WORKSPACE_NAME} && \
	terraform apply tf.plan && \
	terraform output -json > tf_op.json

.PHONY: destroy
destroy: terraform/.terraform ## Destroy deployed infrastructure
	$(info Workspace: ${TF_WORKSPACE_NAME})
ifdef PROTECTED_STACK
	$(error "Can't destroy ${TF_STACK_NAME}")
endif
	cd terraform && \
	terraform workspace select ${TF_WORKSPACE_NAME} && \
	terraform apply -destroy -auto-approve ${TF_VAR_ARGS} && \
	terraform workspace select default && \
	terraform workspace delete ${TF_WORKSPACE_NAME}

.PHONY: component-tests
component-tests: ## Run component tests against deployed infrastructure
	cd test &&\
	poetry run pytest

#------ Helper Targets ------#

.PHONY: tf-force-init
tf-force-init: ## Force terraform to re-initialize
	rm -rf terraform/.terraform
	$(call tf_init)

terraform/.terraform: # hidden target for terraform initialization
	$(call tf_init)


#------ Functions ------#

define tf_init
	cd terraform && \
	terraform init -backend-config=tfvars/${AWS_ENV}-backend.tfvars
endef

define run_unit_tests
    @rm -rf src/${1}/coverage.xml && \
	poetry run python -m  pytest --cov=src/${1} --cov-append --cov-report xml --cov-report term --cov-report html src/${1} && \
	mv coverage.xml src/${1}
endef

define package_lambda
	@cd src/${1}/ && \
	poetry build --format wheel && \
	poetry run pip install --quiet -t package dist/*.whl  && \
	find package -exec touch -t 202201010000 {} \; && \
	zip -X -qg ../../build/$(1).zip *.py -x "test_*" && \
	cd package && \
	zip -X -qr ../../../build/$(1).zip . -x '*.pyc' -x "__pycache__/*" && \
	cd .. && \
	rm -rf package dist
endef

define package_layer
	@cd src/$(1)/ && \
	poetry build --format wheel &&\
	poetry run pip install --quiet -t package/python dist/*.whl && \
	cp *.py package/python/ &&\
	find package -exec touch -t 202201010000 {} \; && \
	cd package && \
	zip -X -qr ../../../build/$(1).zip . -x '*.pyc' -x "__pycache__/*" && \
	cd .. && \
	rm -rf package dist
endef

define update_python_deps
	@ echo Updating $(1)
	@ cd $(1) &&\
	poetry update
endef
