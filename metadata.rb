maintainer       "Skystack Limited."
maintainer_email "support@skystack.com"
license          "Apache 2.0"
description      "SkyStack Configuration Initializer"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0.0"
recipe           "skystack::default", "This recipe acts as a front controller for loading configurations in a organised way."
recipe           "skystack::firewall", "Automatically locks down a server during the bootrap process."
recipe           "skystack::sites", "Sets up a web server and virtual hosting environment."
recipe           "skystack::script", "Runs ad hoc scripts during the build process."
recipe           "skystack::databases", "Sets up a database."
%w{ apache2 php mysql }.each do |cb|
  depends cb
end
