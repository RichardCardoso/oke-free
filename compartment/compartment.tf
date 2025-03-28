# Create the Kubernetes compartment
resource "oci_identity_compartment" "k8s_compartment" {
  name          = var.compartment_name
  description   = var.compartment_name
  enable_delete = true
}

# Create a budget for the created compartment
resource "oci_budget_budget" "k8s_budget" {
  compartment_id = oci_identity_compartment.k8s_compartment.compartment_id  # Reference the newly created compartment
  target_type    = "COMPARTMENT"
  amount         = var.budget_amount
  reset_period   = "MONTHLY"

  targets = [oci_identity_compartment.k8s_compartment.compartment_id]

  # Ensure that the compartment is created before the budget
  depends_on = [oci_identity_compartment.k8s_compartment]
}

# Create an alert for the budget when 80% is reached
resource "oci_budget_alert_rule" "budget_alert_80" {
  budget_id      = oci_budget_budget.k8s_budget.id
  type           = "ACTUAL"
  threshold      = 80
  threshold_type = "PERCENTAGE"
  recipients     = var.alert_email
}

# Create an alert for the budget when 100% is reached
resource "oci_budget_alert_rule" "budget_alert_100" {
  budget_id      = oci_budget_budget.k8s_budget.id
  type           = "ACTUAL"
  threshold      = 100
  threshold_type = "PERCENTAGE"
  recipients     = var.alert_email
}
