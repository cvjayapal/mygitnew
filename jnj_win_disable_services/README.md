# jnj_win_disable_services Cookbook

 To stop the Internet connection sharing (ics)/SharedAccess service 

## Requirements
 ### Platforms

- windows_server-2008r2

### Chef

- Chef 12.0 or later

### Cookbooks
- verrsion-0.1.0
## Attributes
 - No Attributes in this Cookbook
## Usage

### jnj_win_disable_services::default
 
 e.g.
Just include `jnj_win_disable_services` in your node's `run_list`:
 
 {
  "name":"my_node",
  "run_list": [
    "recipe[jnj_win_disable_services]"
  ]
}


## License and Authors

Authors: TODO: Krishna

