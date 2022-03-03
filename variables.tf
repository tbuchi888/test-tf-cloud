variable "custom_image_resource_group_name" {
  description = "The name of the Resource Group in which the Custom Image exists."
  default = "demo_packer_tf_custom_images_990"
}

variable "custom_image_name" {
  description = "The name of the Custom Image to provision this Virtual Machine from."
  default = "my-ubuntu-20-04-nginx-via-pakcer-tf-1"
}

variable "tf_host_source_pip1" {
  description = "The Public IP of the host on which terraform is executing. Example: echo \"TF_VAR_tf_host_source_pip=`curl ifconfig.io`\""
}

variable "tf_host_source_pip2" {
  description = "The Public IP of the host on which terraform is executing. Example: echo \"TF_VAR_tf_host_source_pip=`curl ifconfig.io`\""
}

variable "deploy_resource_group" {
  description = "Resource group name of the VM deployed to.."
  default = "demo_packer_tf_990"
}

variable "deploy_location" {
  description = "It must be the same as the region in which the custom image is stored."
  default = "japaneast"
}
