# FSI Controls

This blueprint provides a set of controls for Financial Services institutions.

![Diagram](diagram.png)

## Examples

### Basic Example

```hcl
module "fsi-controls" {
  source = "./fabric/blueprints/compliance/fsi-controls"
  # ...
}
```

<!-- TFDOC OPTS files:1 show_extra:1 -->
<!-- BEGIN TFDOC -->
## Files

| name | description | modules | resources |
|---|---|---|---|
| [import.tf](./import.tf) | None |  |  |
| [kms.tf](./kms.tf) | None |  |  |
| [log-export.tf](./log-export.tf) | None |  |  |
| [main.tf](./main.tf) | None |  |  |
| [provider.tf](./provider.tf) | None |  |  |
| [variables.tf](./variables.tf) | Module variables. |  |  |

## Variables

| name | description | type | required | default | producer |
|---|---|:---:|:---:|:---:|:---:|
| | | | | | |

## Outputs

| name | description | sensitive | consumers |
|---|---|:---:|---|
| | | | |
<!-- END TFDOC -->
