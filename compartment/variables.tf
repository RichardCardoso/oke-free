variable "compartment_name" {
}

variable "budget_amount" {
  description = "The budget amount in the currency defined in your tenancy."
  type        = number
}

variable "alert_email" {
  description = "The email address to send budget alerts to."
  type        = string
}