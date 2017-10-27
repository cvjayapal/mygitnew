####################### reboot Cookbook #############################

Allows one to reboot the server after a successfull chef run


##### Requirements

##### Platforms

 - CentOS
 - Ubuntu

### Chef

- Chef 12.0 or later

### Cookbooks

- jnj_reboot version 0.1.0

## Attributes


## Usage
e.g.
### reboot::default

{
  "name":"my_node",
  "run_list": [
    "recipe[jnj_reboot]"
  ]
}





## License and Authors

Authors: TODO: krishna

