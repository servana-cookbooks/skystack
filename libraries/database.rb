module SkyStack
  module Mysql
    module Database
      def db
        Gem.clear_paths
        require 'mysql2'
        @@db ||= Mysql2::Client.new ({ :host => new_resource.host, :username => new_resource.root_username, :password =>  new_resource.root_password })
      end
    end
  end
end