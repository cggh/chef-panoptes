install_dir = node["panoptes"]["install_root"] + "/" + node["panoptes"]["git"]["revision"]
build_dir = install_dir + "/build"

cookbook_file build_dir + "/DQXServer/monitor.py" do
  source "monitor.py"
  user node["panoptes"]["user"]
  group 'www-data'
end

ruby_block "Replace name" do
  block do
    sed = Chef::Util::FileEdit.new(build_dir + "/DQXServer/.html")
    sed.search_file_replace(/#logging.basicConfig(level=logging.DEBUG)/, "import monitor\nmonitor.start(interval=1.0)\n")
    sed.write_file
  end
  notifies :start, "service[apache]"
end

service "apache" do
  action :nothing
end
