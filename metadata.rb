name             "privoxy"
maintainer       "Rostyslav Fridman"
maintainer_email "rostyslav.fridman@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures privoxy"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          "1.0.1"

supports "centos"
supports "debian"
supports "fedora"
supports "redhat"
supports "ubuntu"

depends "checkinstall"
depends "yum-epel"
