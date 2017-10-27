# jnj_win_vpcx_task_uploadmonitormetrics Cookbook

Custom metrics to Amazon Cloudwatch

## Requirements

### Platforms

- windows-2008r2

### Chef

- Chef 12.0 or later

## Attributes

node['scm_hosting']['platform'] ---> It considor AWS Platform
node['scm']['buildtype']       ----> It considor buildworkflow
node['win_jnj']['vpcx_path'] ---> C:\\ProgramData\\JnJ\\Its_core\\vpcx

## Usage

### jnj_win_vpcx_task_uploadmonitormetrics::default

Just include `jnj_win_vpcx_task_uploadmonitormetrics` in your node's `run_list`:

{
  "name":"my_node",
  "run_list": [
    "recipe[jnj_win_vpcx_task_uploadmonitormetrics]"
  ]
}

## License and Authors

Authors: TODO: Krishna


