# test-tf-cloud 
This repository is a test of using [Terraform Cloud](https://cloud.hashicorp.com/products/terraform) to deploy VM and VNet, Subnets, NSG etc..., to Azure.
## Reference
I used the following manual as a reference.
+ https://docs.microsoft.com/ja-jp/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure
+ https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
+ https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples
+ https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md

## Variables
The following must be added as variables on Terraform Cloud.
You must also pre-create a Service Principal for the Azure connection and add the following environment variables
- ARM_SUBSCRIPTION_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID

<img width="823" alt="ScreenShot 2022-03-03 16 42 17" src="https://user-images.githubusercontent.com/17949085/156519368-92cc5ab5-0380-4717-a769-8311b93e04a3.png">
