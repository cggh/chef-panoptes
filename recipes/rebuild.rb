include_recipe 'nodejs'

install_dir = node["panoptes"]["install_root"] + "/" + node["panoptes"]["git"]["revision"]

nodepath=install_dir + "/webapp"

#Update
nodejs_npm "npm" do
end

execute 'npm-update' do
  command "npm install -g npm && npm cache clean -f && npm install -g n"
  cwd nodepath
end

execute 'n-stable' do
  command "n stable"
  cwd nodepath
  action :nothing
  subscribes :run, "execute[npm-update]"
end

nodejs_npm "gulp-cli" do
  action :nothing
  subscribes :install, "execute[n-stable]"
end

nodejs_npm "esprima" do
  user node["panoptes"]["user"]
  path nodepath
  action :nothing
  subscribes :install, "execute[gulp-cli]"
end

nodejs_npm 'panoptes' do
  action :nothing
  json true
  user node["panoptes"]["user"]
  path nodepath
  subscribes :install, "nodejs_npm[esprima]"
end

execute 'run-build-js' do
  command "npm run build"
  cwd nodepath
  action :nothing
  user node["panoptes"]["user"]
  subscribes :run, "nodejs_npm[panoptes]"
end

ruby_block 'set_app_server' do
  block do
    file = Chef::Util::FileEdit.new(install_dir + "/webapp/dist/index.html")
    file.search_file_replace('localhost:8000', node["panoptes"]["server_name"])
    file.write_file
  end
  action :nothing
  subscribes :run, "execute[run-build-js]"
  not_if { ::File.exists?(install_dir + "/webapp/scripts/Local.example/_SetServerUrl.js") }
end

