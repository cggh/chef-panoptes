
remote_directory node["panoptes"]["source_dir"] do
  files_mode '0440'
  files_owner node["panoptes"]["user"] 
  owner node["panoptes"]["user"] 
  mode '0770'
  group 'www-data'
  source "sampledata"
end
