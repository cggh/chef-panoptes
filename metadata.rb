name             'panoptes'
maintainer       'CGGH'
maintainer_email 'info@cggh.org'
license          'All rights reserved'
description      'Installs/Configures panoptes'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apt', '= 2.7.0'
depends 'build-essential', '= 2.2.3'
depends 'apache2', '= 3.2.2'
depends 'git', '= 4.0.2'
depends 'python', '= 1.4.6'
depends 'nodejs', '= 2.0.0'
depends 'mysql', '~> 8.0.0'
depends 'mysql2_chef_gem', '~> 1.0.1'
depends 'database', '= 4.0.6'
depends 'swap', '= 0.3.8'
depends 'sssd_ldap', '~> 3.1.0'
