# logrotate Cookbook

 logrotate is run as a daily cron job

#### Requirements
### Platforms

- CentOS_7.1/7.2
- Ubuntu_14.04

### Chefs

- Chef 12.0 or later


## Attributes
 
 -This cookbook  no Attributes

#####Templates

 -- In this Cookbook used customised templates this are 

     1.) Standlone.xml file 
                  # no packages own wtmp and btmp -- we'll rotate them here
                    /var/log/wtmp {
                        monthly
                        create 0664 root utmp
	                    minsize 1M
                        rotate 1
                    }

                    /var/log/btmp {
                        missingok
                        monthly
                        create 0600 root utmp
                        rotate 1
                    }
## Usage

### logrotate::default

{
  "name":"my_node",
  "run_list": [
    "recipe[logrotate]"
  ]
}


Authors: TODO: Krishna

