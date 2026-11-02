/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

/*----------------------------------------------------------------------*/
/* Security Hub | Variable Definition                                   */
/*----------------------------------------------------------------------*/

variable "securityhub_parameters" {
  type        = any
  description = "Organization Security Hub CSPM central configuration, finding aggregator, and configuration policies."
  default     = {}
}

variable "securityhub_defaults" {
  type        = any
  description = "Default values merged into each entry of securityhub_parameters."
  default     = {}
}
