default["panoptes"]["name"] = "panoptes"
default["panoptes"]["title"] = "panoptes"
default["panoptes"]["database"] = "panoptes"
default["panoptes"]["database_server"] = "127.0.0.1"
default['panoptes']['database_data_dir'] = "/data/storage/mysql"
default['panoptes']['database_tmp_dir'] = "/tmp"
default["panoptes"]["db_username"] = "panoptes"
default["panoptes"]["db_password"] = "1234"
default['panoptes']['database_buffer_pool_size'] = "2G"
default['panoptes']['swap'] = 1024
default['mysql']['server_root_password'] = "1234"
#Note that the user running git won't have ssh access so can't really change this
default["panoptes"]["git_root"] = 'https://github.com/cggh'

default["panoptes"]["user"] = "panoptes"
default["panoptes"]["uid"] = "5555"
default["panoptes"]["password"] = "1234"
default["panoptes"]["home"] = "/home/panoptes"

default["panoptes"]["install_root"] = "/home/panoptes"
default["panoptes"]["path"] = "/current"

default["panoptes"]["git"]["branch"] = "master"

default["panoptes"]["extra_head_js"] = ''
default["panoptes"]["extra_tail_js"] = ''

default["panoptes"]["source_dir"] = "/data/storage/panoptes/source"
default["panoptes"]["base_dir"] = "/data/storage/panoptes/base"
default["panoptes"]["auth_file"] = ""
default["panoptes"]["cas"]["service"] = ""
default["panoptes"]["cas"]["logout"] = ""
default["panoptes"]["cas"]["url"] = ""

default["panoptes"]["virtualenv"] = "/panoptes_virtualenv"

default['panoptes']['server_name'] = "panoptes"
