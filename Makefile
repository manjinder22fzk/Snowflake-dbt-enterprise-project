.PHONY: help
help:
	@echo "Targets:"
	@echo "  setup             - create venv + install tools"
	@echo "  fmt               - format sql/yaml"
	@echo "  lint              - lint dbt project (and sql if configured)"
	@echo "  dbt-deps          - install dbt deps"
	@echo "  dbt-debug         - dbt debug"
	@echo "  dbt-build-dev     - dbt build in DEV target"
	@echo "  tf-init-dev       - terraform init (dev)"
	@echo "  tf-plan-dev       - terraform plan (dev)"
	@echo "  tf-apply-dev      - terraform apply (dev)"

setup:
	python -m venv .venv && . .venv/Scripts/activate && pip install -U pip && pip install dbt-snowflake sqlfluff

dbt-deps:
	cd dbt && dbt deps

dbt-debug:
	cd dbt && dbt debug

dbt-build-dev:
	cd dbt && dbt build --target dev

tf-init-dev:
	cd infra/terraform/envs/dev && terraform init

tf-plan-dev:
	cd infra/terraform/envs/dev && terraform plan

tf-apply-dev:
	cd infra/terraform/envs/dev && terraform apply -auto-approve

