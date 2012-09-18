log_level                :info
log_location             STDOUT

node_name                ENV['USER']

knife[:aws_access_key_id]     = ENV['AWS_ACCESS_KEY_ID']
knife[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']
knife[:aws_ssh_key_id]        = "#{ENV['CHEF_ORGANIZATION']}-ec2"
knife[:region]                = 'us-east-1'

knife[:image]                 = 'ami-82fa58eb' # (Ubuntu 12.04 by Canonical)
knife[:ssh_user]              = 'ubuntu'
knife[:ssh_attribute]         = 'ec2.public_hostname'
knife[:use_sudo]              = true
knife[:ssh_identity_file]     = ENV['SSH_IDENTITY_FILE']
knife[:no_host_key_verify]    = true
knife[:bootstrap_version]     = '10.14.2'
