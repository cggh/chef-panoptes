install_dir = node["panoptes"]["install_root"] + "/" + node["panoptes"]["git"]["revision"]
build_dir = install_dir + "/build"

cookbook_file build_dir + "/DQXServer/monitor.py" do
  source "monitor.py"
  user node["panoptes"]["user"]
  group 'www-data'
end

ruby_block "Install monitor" do
  block do
    sed = Chef::Util::FileEdit.new(build_dir + "/DQXServer/wsgi_server.py")
    sed.search_file_replace(/#logging.basicConfig\(level=logging.DEBUG\)/, "import monitor\nmonitor.start\(interval=1.0\)\n")
    sed.write_file
  end
  notifies :start, "service[apache2]"
end

service "apache2" do
  action :nothing
end
