# jnj_win_facts Cookbook

 Collects the facts about the system based on the avaialable metadata and sets

## Requirements
### Platforms

- windows-2008r2

### Chef

- Chef 12.0 or later

### Cookbooks

- version-0.1.0

## Attributes

 node['jnj_win_facts']['directory'] ---> to create multiple directores
 node['jnj_win_facts']['file'] ---> To create "C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\aws_facts.ps1" file
 node['jnj_win_facts']['path'] ---> To delete "C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\scm_facts.ps1" file

## Usage

### jnj_win_facts::default

Just include `jnj_win_facts` in your node's `run_list`:

{
  "name":"my_node",
  "run_list": [
    "recipe[jnj_win_facts]"
  ]
}


## License and Authors

Authors: TODO: Krishna

