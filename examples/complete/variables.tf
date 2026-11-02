/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

# variable "metadata" {
#   type = any
# }

/*----------------------------------------------------------------------*/
/* Security Hub | Variable Definition                                   */
/*----------------------------------------------------------------------*/
variable "securityhub_parameters" {
  type        = any
  description = "Security Hub parameteres to configure the wrapper module"
  default     = {}
}

variable "securityhub_defaults" {
  type        = any
  description = "Security Hub default parameteres for the wrapper module"
  default     = {}
}
