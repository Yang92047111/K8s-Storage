.PHONY: setup deploy test clean unit-test status

setup:
	@echo "🚀 Setting up Kind cluster..."
	@bash scripts/setup-kind.sh

deploy:
	@echo "📦 Deploying application..."
	@bash scripts/deploy.sh

test:
	@echo "🧪 Running E2E tests..."
	@bash scripts/test.sh

unit-test:
	@echo "🧪 Running unit tests..."
	@cd go-app && go test -v ./...

status:
	@bash scripts/status.sh

clean:
	@echo "🧹 Cleaning up..."
	@kind delete cluster --name storage-demo || true

all: setup deploy test

help:
	@echo "🚀 Kubernetes Storage Experiment"
	@echo ""
	@echo "Available commands:"
	@echo "  setup      - Create Kind cluster"
	@echo "  deploy     - Build & deploy manifests & app"
	@echo "  test       - Run E2E tests with persistence validation"
	@echo "  unit-test  - Run Go unit tests"
	@echo "  status     - Show project and cluster status"
	@echo "  clean      - Delete Kind cluster"
	@echo "  all        - Complete workflow: setup + deploy + test"
	@echo ""
	@echo "Quick start: make all"