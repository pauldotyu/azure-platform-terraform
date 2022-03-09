# azure-platform-terraform

The intent of this repo is to build foundational Azure Landing Zone components using the [Azure/caf-enterprise-scale](https://registry.terraform.io/modules/Azure/caf-enterprise-scale/azurerm/latest) module which includes the following resources:

- Customized management group structure
- Custom policies and assignments at root and other MG scopes under the "Landing zones" MG
  - Customizations can be found in the lib/\* directories.
- Centralized log analytics workspace for SecOps

This repo uses Terraform Cloud for remote storage and remote runs. If you are using some other remote state solution, please update `backend.tf` accordingly.

To initialize your backend, you'll need to supply additional backend configs. This repo uses a partial backend configuration file named `config.remote.tfbackend` which is kept as a secret in the github repo. The config file looks like this:

```sh
workspaces { name = "<MY_TF_WORKSPACE_NAME>" }
hostname     = "app.terraform.io"
organization = "<MY_TF_ORGANIZATION_NAME>"
```

To initialize the backend, you can pass in the \*.tfbackend file at runtime like this;

```sh
terraform init --backend-config=config.remote.tfbackend
```
