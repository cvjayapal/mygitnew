##### jnj_rsyslog Cookbook  

Installs rsyslog to replace sysklogd for client and/or server use. By default, server will be set up to log to files.

### Requirements 

### Platforms

 - CentOS
 - Ubuntu

###### Chef

 - Chef 12.0 or later

##### Cookbooks

 -  jnj_rsyslog
 -  Version 0.1.0

###### Other

To use the recipe[rsyslog::default] recipe, you'll need to set up a role to search for. See the Recipes, and Examples sections below.

## Attributes

 - This cookbook  no Attributes

####### Templates

 - Customised template

###### Usage

Use recipe[jnj_rsyslog] to install and start rsyslog as a basic configured service for standalone systems.

e.g.

### rsyslog::default
{
  "name":"node name",
  "run_list": [
    "recipe[jnj_rsyslog]"
  ]
}



## License and Authors

Authors: TODO: Krishna