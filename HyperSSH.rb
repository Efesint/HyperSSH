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

# loop starts here
loop do
  puts "Enter the server alias (or 'q' to quit)"
  server_alias = gets.chomp.strip

break if server_alias == "q"

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
end
else
Dir.mkdir(File.expand_path("~/.ssh")) unless Dir.exist?(File.expand_path("~/.ssh"))

  puts "Let's write the config."
  system("touch ~/.ssh/servers.yaml")

  puts "Please, write the alias "
  server_alias = gets.chomp.strip
   if server_alias.empty?
    puts "Alias cannot be empty!"
     exit
   end

  puts "Write the username"
  server_user = gets.chomp.strip
  if server_user.empty?
     puts "User cannot be empty!"
     exit
    end

  puts "Write name of server"
  server_name = gets.chomp.strip
  if server_name.empty?
  puts "Server name cannot be empty!"
  exit
 end

  puts "Write the host IPv4 address"
  server_host = gets.chomp.strip
  if server_host.empty?
  puts "Host cannot be empty!"
  exit
  end

  puts "Write the port"
  server_port = gets.chomp
  server_port = server_port.to_i
   if server_port == 0
   puts "The standard port 22 is set."
   server_port = 22
  end

config_content = <<~YAML
servers:
 - alias: #{server_alias}
   name: "#{server_name}"
   host: #{server_host}
   user: #{server_user}
   port: #{server_port}
YAML
File.write(File.expand_path("~/.ssh/servers.yaml"), config_content)

end
