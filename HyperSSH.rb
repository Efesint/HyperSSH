#!/usr/bin/ruby

require 'yaml'

puts "HyperSSH v1.0"
puts " "

if File.exist?(File.expand_path("~/.ssh/servers.yaml"))
  puts "Config found"
  puts " "
  config = File.read(File.expand_path("~/.ssh/servers.yaml"))
  puts config
  puts " "
  
  config = YAML.load_file(File.expand_path("~/.ssh/servers.yaml"))
  servers = config["servers"]
  puts "Enter the server alias"
  server_alias = gets.chomp

  selected_server = servers.find { |s| s["alias"] == server_alias }
     if selected_server
       host = selected_server["host"]
       user = selected_server["user"]
       port = selected_server["port"]
       ssh_command = "ssh #{user}@#{host}"
       
          if port && port != 22
            ssh_command = "ssh -p #{port} #{user}@#{host}"
             end 
          if File.exist?(File.expand_path("~/.ssh/id_rsa.pub"))
           system(ssh_command)
      
            elsif File.exist?(File.expand_path("~/.ssh/id_ed25519.pub"))
              system(ssh_command)

            elsif File.exist?(File.expand_path("~/.ssh/id_ecdsa.pub"))
                    system(ssh_command)
               else
                 puts "Connection key not found!"
                puts "Please create a connection key for your server."
        end

     else
       puts "Server not found!"
end

else
  puts "Please write the server.yaml"
end
