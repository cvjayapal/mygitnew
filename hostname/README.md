############ jnj_hostname Cookbook #############

Sets hostname and FQDN of the node. 

############### Requirements

### Platforms

- CentOS_7.1/7.2
- Ubutnu_14.04

### Chef

- Chef 12.0 or later

### Cookbooks

- jnj_hostname version 0.1.0

## Attributes

default['host']['name'] -- Hostname to set


## Usage

### hostname::default

{
  "name":"my_node",
  "run_list": [
    "recipe[hostname]"
  ]
}


## License and Authors

Authors: TODO: Krishna




