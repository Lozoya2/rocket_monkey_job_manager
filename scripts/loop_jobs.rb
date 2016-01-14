require 'jenkins_api_client'
require 'byebug'

# This script chains Jenkins jobs into a loop. Simply match a list of jobs and
# every result that is included in this list will be chained into a loop. 
unless File.exist?(File.expand_path(File.dirname(__FILE__))+'/config/login.yml')
  puts 'Error: Create and configure /config/login.yml from login_template.yml'
  exit
end
debugger
@client = JenkinsApi::Client.new(YAML.load_file(File.expand_path(
  "../../config/login.yml", __FILE__)))

# To properly grab all associated Jenkins jobs for a particular app/shard, make 
# sure to match the prefix pattern for example:
#
# Look here: http://104.154.43.59:8080/computer/ssapislave1/
# We have tests of the form: 
# PROD_SS_API_ssapislave1_ReleaseSHARD3_{index}_{test_name} and
# PROD_SS_API_ssapislave1_ReleaseSHARD4_{index}_{test_name}
#
# So then we would want to have the following:
# shard3_jobs = @client.job.list('PROD_SS_API_ssapislave1_ReleaseSHARD3')
# shard4_jobs = @client.job.list('PROD_SS_API_ssapislave1_ReleaseSHARD4')
#
# Which will give us all jobs tied into shard 3 and shard 4, respectively. 
shard3_jobs = @client.job.list('')
shard4_jobs = @client.job.list('')

job_list = [shard3_jobs, shard4_jobs]

# If any jobs exist that should not be integrated into the main loop, then list 
# them here, for example:
#
# If we have a test of the form:
# PROD_SS_API_ssapislave1_ReleaseSHARD3_{index}_dont_loop_me_functional_test
# then we can add the test as follows:
#
# jobs_not_to_chain = [/dont_loop_me_functional_test/]
# 
# This will skip said tests on both shards so you can manage them manually
jobs_not_to_chain = []

jobs_not_to_chain.each{|s|
  shard3_jobs.delete_if{|t| s=~t}
  shard4_jobs.delete_if{|t| s=~t}
}

job_list.each{|s|
  # This only chains jobs sequentially, does not create the closing loop
  @client.job.chain(s, 'success', ['all'])
  # Loop is created here
  @client.job.update_freestyle({
    name: s.last, child_projects: s.first, child_threshold: 'success'
  })
}