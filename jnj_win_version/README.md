# jnj_win_version Cookbook

To Create two files in "C:\\ProgramData C:\\ProgramData\\JnJ" & "C:\\ProgramData\\JnJ\\Its_core" and add the version  

## Requirements
 
### Platforms
 
- windows-2008r2

### Chef

- Chef 12.0 or later

## Attributes

node['jnj_win_version']['file'] ---> To create the "C:\\Windows\\its_core_version.txt" file
node['jnj_win_version']['path'] ---> To create the "C:\\ProgramData\\JnJ\\Its_core\\version.txt" file
## Usage

### jnj_win_version::default
 
Just include `jnj_win_version` in your node's `run_list`:
 
{
  "name":"my_node",
  "run_list": [
    "recipe[jnj_win_version]"
  ]
}

 
## License and Authors

Authors: TODO: Krishna

