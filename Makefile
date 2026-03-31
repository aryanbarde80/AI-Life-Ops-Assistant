.PHONY: all build test deploy clean

# ACOS Master Makefile
# Orchestrates the 10+ DB Mesh and 8+ Microservices

NAMESPACE ?= acos-system
CLUSTER_NAME ?= acos-hyper-cluster
REGION ?= us-east-1

help:
	@echo "ACOS Platform Ecosystem Commands:"
	@echo "  make up          - Start all docker-compose services"
	@echo "  make down        - Tear down all services"
	@echo "  make k8s-apply   - Deploy to Kubernetes cluster"
	@echo "  make helm-install- Install Helm chart"
	@echo "  make terraform   - Apply Terraform infrastructure"

up:
	docker-compose up -d --build

down:
	docker-compose down -v

k8s-apply:
	kubectl apply -f k8s/ -n $(NAMESPACE)

helm-install:
	helm upgrade --install acos-release helm/acos-chart -n $(NAMESPACE)

terraform:
	cd terraform && terraform init && terraform apply -auto-approve

lint:
	npm run lint && flake8 . && cargo clippy && go vet ./...
