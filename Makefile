all: package

CHART_DIR := helm/system
CHARTS := cert-manager cilium ingress-nginx

REPO_URL := https://Ujstor.github.io/helm-charts-system

package: $(CHARTS)

$(CHARTS):
	@echo "Packaging $@ chart..."
	@helm dependency build $(CHART_DIR)/$@ 

.PHONY: all package $(CHARTS)
