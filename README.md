# AWS VPC module for Terraform

A lightweight VPC module for Terraform.

## Usage

```hcl
module "vpc" {
  source = "github.com/jamtur01/tf_vpc"

  name = "vpc_name"
  key_name = "james"

  cidr = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24"]
  private_subets = ["10.0.100.0/24"]
}
```

See `variables.tf` for additional configurable variables.

## License

MIT

