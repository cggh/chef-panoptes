
remote_directory node["panoptes"]["source_dir"] do
  files_mode '0440'
  files_owner node["panoptes"]["user"] 
  owner node["panoptes"]["user"] 
  mode '0770'
  group 'www-data'
  source "sampledata"
  action :create_if_missing
end

http_request 'load_sample_data' do
  url 'http://' + node["panoptes"]["server_name"] + '/api?datatype=custom&respmodule=panoptesserver&respid=fileload_dataset&ScopeStr=all&SkipTableTracks=false&datasetid=Samples_and_Variants'
end

