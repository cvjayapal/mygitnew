node.default['scm_mount']['device'] = '/dev/sdb'
node.default['scm_mount']['fstype'] = 'ext2'
node.default['scm_mount']['title'] =  '/rl'
default['scm_mount']['directory'] = node['scm_mount']['title']
node.default['scm_mount']['options'] = 'defaults'
node.default['scm_mount']['ensure'] = 'mounted'
node.default['scm_mount']['owner'] = 'root'
node.default['scm_mount']['group'] =  'disk'
