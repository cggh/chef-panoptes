name             'panoptes'
maintainer       'CGGH'
maintainer_email 'info@cggh.org'
license          'All rights reserved'
description      'Installs/Configures panoptes'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apt'
depends 'apache2', '~> 3.2.2'
depends 'git'
depends 'python'
depends 'nodejs'
depends 'mysql', '~> 6.0'
depends 'mysql2_chef_gem', '~> 1.0.1'
depends 'database'
depends 'swap'
