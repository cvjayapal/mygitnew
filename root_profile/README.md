##################### jnj_root_profile Cookbook ######################

Displaying prasent working directory insted of " ~ ", which is applicable only for sudo users

######Platforms

Debian/Ubuntu14.04
 - CentOS_7.1/7.2


#######Chef

Chef 12.1+

#########Cookbooks

 - jnj_root_profile version 0.1.0

e.g.
### jnj_root_profile::default


## Attributes
 
 -This cookbook  no Attributes

#####Template files

 -In This cookbook used customised temples. this are 
 1.) .bashrc ----  Create separate history file for sudo users
 2.) .bash_profile --- Create separate history file for sudo users
 3.) .profile ---- To change the user profile PS1 value 
 4.) histdir_cleanup (0 8 * * * root cd $HOME/.histdir && find . -type f -mtime +90 -print -exec rm {} \; >> /var/log/histdir.log 2>&1) --- cleanup of old files in /root/.histdir


## Usage

### root_profile::default

e.g.
Just include `jnj_root_profile` in your node's `run_list`:


{
  "name":"my_node",
  "run_list": [
    "recipe[jnj_root_profile]"
  ]
}



## License and Authors

Authors: TODO: Krishna

