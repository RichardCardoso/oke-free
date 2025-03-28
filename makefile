# Define targets
.PHONY: deploy apply

K8S_COMPARTMENT_NAME := kubernetes
OCI_REGION := us-ashburn-1
NEW_KUBECONFIG := $(TEMP)/new_kubeconfig
MERGED_KUBECONFIG := $(TEMP)/merged_kubeconfig
EXISTING_KUBECONFIG := $(USERPROFILE)/.kube/config
NEW_CONTEXT_NAME := oke-free

# Default task to retrieve, merge, and update kubeconfig
kube-setup: retrieve-kubeconfig merge-kubeconfig use-new-context

# Task to retrieve kubeconfig from OCI
retrieve-kubeconfig:
	@echo "Retrieving kubeconfig for cluster in compartment '$(K8S_COMPARTMENT_NAME)'..."
	oci ce cluster create-kubeconfig --cluster-id $$(oci ce cluster list --compartment-id $$(oci iam compartment list --all --query "data[?name=='$(K8S_COMPARTMENT_NAME)'].id | [0]" --raw-output) --query "data[0].id" --raw-output) --file "$(NEW_KUBECONFIG)" --region $(OCI_REGION) --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT

# Task to merge the new kubeconfig with the existing one
merge-kubeconfig:
	@echo "Merging kubeconfig files..."
	@export KUBECONFIG="$(EXISTING_KUBECONFIG);$(NEW_KUBECONFIG)" && kubectl config view --flatten > "$(MERGED_KUBECONFIG)"
	@cat "$(subst \,/,$(MERGED_KUBECONFIG))" > "$(subst \,/,$(EXISTING_KUBECONFIG))"

# Task to get context after merging
use-new-context:
	@echo "Switching to the newly added context..."
	@export KUBECONFIG="$(NEW_KUBECONFIG)" && \
	context_name=$$(kubectl config current-context) && \
	export KUBECONFIG="$(EXISTING_KUBECONFIG)" && \
	kubectl config use-context $$context_name

# Apply all the necessary targets
deploy:
	env.bat
	tofu apply --auto-approve

destroy:
	env.bat
	tofu destroy -auto-approve
