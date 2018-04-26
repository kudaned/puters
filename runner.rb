require 'aws-sdk'
require 'yaml'
require 'pry'

require './lib/puters'
require './lib/validate_options'

env = ARGV[0]
search_term = ARGV[1]
tags = { name: search_term }
errors = [Aws::EC2::Errors, StandardError]

validator = ValidateOptions.new(env, search_term)
exit if validator.has_errors
# exit if ValidateOptions.new(env, search_term).has_errors

begin

  puters = Puters.new
  client = puters.ec2_client
  data = puters.fetch_cluster_ips(client, env, tags)
  puters.display data

rescue *errors => e
  puts e.message
end
