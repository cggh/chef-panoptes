include_recipe 'nodejs'

install_dir = node["panoptes"]["install_root"] + "/" + node["panoptes"]["git"]["revision"]

nodepath=install_dir + "/webapp"

#Update
nodejs_npm "npm" do
end

execute 'npm-update' do
  command "npm install -g npm && npm cache clean -f && npm install -g n && n stable"
  cwd nodepath
end

nodejs_npm "gulp-cli" do
  action :install
end

nodejs_npm 'panoptes' do
  action :nothing
  json true
  user node["panoptes"]["user"]
  path nodepath
  subscribes :install, "nodejs_npm[gulp-cli]"
end

execute 'run-build-js' do
  command "npm run build"
  cwd nodepath
  action :nothing
  user node["panoptes"]["user"]
  subscribes :run, "nodejs_npm[panoptes]"
end

