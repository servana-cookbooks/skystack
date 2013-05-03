  if File.exists?("/opt/skystack/etc/userdata.conf")

    File.open('/opt/skystack/etc/userdata.conf').each_line{ |s|

      config = s.split("=")
     
      if config[0] == "API_USER"
        ApiUser = config[1]
      end

      if config[0] == "API_TOKEN"
        ApiToken = config[1]
      end

      if config[0] == "STACKADMIN_PUB"
        StackAdminHref = config[1]
      end

       if config[0] == "STACKADMIN_LOGIN"
        StackAdminLogin = config[1]
      end
    }

  end

  if StackAdminLogin && StackAdminHref && ApiToken && ApiUser

    Chef::Log.info "skystack::stackadmin creating a stackadmin called #{ApiUser}"

    u = {}

    u['ssh_keys'] = http_request "get public key" do
      action :get
      url StackAdminHref
      headers({"AUTHORIZATION" => "Basic #{Base64.encode64("#{ApiUser}:#{ApiToken}")}"})
    end

    u['username']= StackAdminLogin
    u['home'] = true
    u['comment'] = "First StackAdmin user"
    u['is_admin'] = true
    u['grant_sudo'] = true
    
    if u['home']
        home_dir = "/home/#{u['username']}"
    elsif u['home_dir']
        home_dir = "#{u['home_dir']}"
    end

    if home_dir
        manage_home = true
    else 
        manage_home = false
    end

    if u['shell']
        user_shell = u['shell']
    else
        user_shell = node['user']['default']['shell']
    end

    user u['username'] do
      shell user_shell
      comment u['comment']
      supports :manage_home => manage_home
      home home_dir
    end
    
    directory "#{home_dir}/.ssh" do
      owner u['username']
      group u['username']
      mode "0700"
    end

    if u['ssh_keys']

      template "#{home_dir}/.ssh/authorized_keys" do
       source "authorised_keys.erb"
       owner u['username']
       group u['username']
       mode "0600"
       variables :ssh_keys => u['ssh_keys']
      end


      if u['is_admin']
        group "sys-admin" do
          action :modify
          members ["#{u['username']}"]
          append true
        end
      end
    end
    
   if u['grant_sudo']
    node.set['authorization']['sudo']['users'] << u
   end

   execute "passwd -l #{u['username']}"

   group "#{u['username']}" do
    members "#{u['username']}"
    append true
   end

  else
    Chef::Log.info "skystack::stackadmin no settings for a stackadmin"
  end
