variable "cloud_id" {
  description = "ID облака"
  type        = string
  default     = "bb1gvp4hi1rte6hlv8prc"
}

variable "folder_id" {
  description = "ID папки"
  type        = string
  default     = "b1g2s09li3uocu4pfl1s"
}

variable "vm_resources" {
  description = "Ресурсы ВМ: ядра, память, доля CPU"
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
}
