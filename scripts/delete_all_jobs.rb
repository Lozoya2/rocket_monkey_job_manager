require 'jenkins_api_client'
require 'byebug'

# This script chains Jenkins jobs into a loop. Simply match a list of jobs and
# every result that is included in this list will be chained into a loop. 

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
ss_api_shard3_jobs = @client.job.list('PROD_SS_API_ssapislave1_ReleaseSHARD3')
ss_api_shard4_jobs = @client.job.list('PROD_SS_API_ssapislave1_ReleaseSHARD4')

# ss_ui_shard3_jobs  = @client.job.list('PROD_SS_UI_ssuislave1_ReleaseSHARD3')
# ss_ui_shard4_jobs  = @client.job.list('PROD_SS_UI_ssuislave1_ReleaseSHARD4')

cwf_shard3_jobs    = @client.job.list('PROD_CWF_cwfslave1_ReleaseSHARD3')
cwf_shard4_jobs    = @client.job.list('PROD_CWF_cwfslave1_ReleaseSHARD4')

job_list = [
  ss_api_shard3_jobs, ss_api_shard4_jobs, cwf_shard3_jobs, cwf_shard4_jobs
]

job_list.each{|s|
  s.each{|x| @client.job.delete(x)}
}