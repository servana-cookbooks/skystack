module SkyStack
  module Mysql
    module Database
      def db
        Gem.clear_paths
        require 'mysql2'
        @@db ||= ::Mysql.new new_resource.host, new_resource.root_username, new_resource.root_password
      end
    end
  end
end