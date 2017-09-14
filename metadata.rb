name 'amazon_ecr_credentials'
maintainer 'Hoegg Software'
maintainer_email 'clayton@hoegg.software'
license 'MIT'
description 'Installs/Configures amazon_ecr_credentials_helper'
long_description 'Installs/Configures amazon_ecr_credentials_helper'
version '0.1.0'
chef_version '>= 12.1' if respond_to?(:chef_version)

issues_url 'https://github.com/hoeggsoftware/amazon_ecr_credentials_cookbook/issues'
source_url 'https://github.com/hoeggsoftware/amazon_ecr_credentials_cookbook'

depends 'git'
depends 'golang'
