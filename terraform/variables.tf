variable "project_name" {
  description = "專案名稱"
  type        = string
  default     = "thsr-booking"
}

variable "environment" {
  description = "環境名稱 (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure 區域"
  type        = string
  default     = "eastasia"
}

variable "database_admin_login" {
  description = "資料庫管理員帳號"
  type        = string
  sensitive   = true
}

variable "database_admin_password" {
  description = "資料庫管理員密碼"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "資源標籤"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "thsr-booking"
    Terraform   = "true"
  }
}