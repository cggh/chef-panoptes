#node recipe installed in base.rb
#
install_dir = node["panoptes"]["install_root"] + "/" + node["panoptes"]["git"]["revision"]

nodepath=install_dir + "/webapp"

nodejs_npm "gulp-cli" do
  action :install
end

directory "clean-node" do
  recursive true
  path nodepath + "/node_modules"
  action :nothing
  subscribes :delete, "nodejs_npm[gulp-cli]"
end

execute 'clean-cache' do
  command "npm cache clean"
  cwd nodepath
  action :nothing
  user node["panoptes"]["user"]
  subscribes :run, "directory[clean-node]"
end

nodejs_npm 'panoptes' do
  action :nothing
  json true
  user node["panoptes"]["user"]
  path nodepath
  ignore_failure true
  subscribes :install, "execute[clean-cache]"
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

nodepath=node["panoptes"]["home"]
nodejs_npm 'requirejs' do
  action :install
  path nodepath
  not_if { node["panoptes"]["dev"] }
end

compiledjs = install_dir + '/webapp/scripts/main-built.js'
execute 'compile-js' do
  command "NODE_PATH=" + nodepath + "/node_modules node scripts/compilejs.js"
  cwd install_dir
  action :nothing
  not_if { node["panoptes"]["dev"] }
  subscribes :run, "nodejs_npm[requirejs]"
  notifies :create, 'file[compiled-js]'
  only_if do ::File.exists?(install_dir + '/scripts/compilejs.js') end
end

file 'compiled-js' do
  content lazy { IO.read(compiledjs) }
  path lazy { install_dir + '/webapp/scripts/main-built-' + node.default[:app][:jsversion] + '.js' }
  owner node["panoptes"]["user"]
  group "www-data"
  sensitive true
  action :nothing
end

