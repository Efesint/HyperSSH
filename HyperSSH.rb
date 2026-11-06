#!/usr/bin/ruby

require 'yaml'
require 'fileutils'

SSH_KEY_PATHS = %w[~/.ssh/id_rsa.pub ~/.ssh/id_ed25519.pub ~/.ssh/id_ecdsa.pub ~/.ssh/*.pub]

def config_path
  File.expand_path(ENV.fetch("SSH_CONFIG", "~/.ssh/servers.yaml"))
end

def prompt_required(prompt, error_message)
  puts prompt
  value = gets.chomp.strip

  unless value.empty?
    return value
  end

  puts error_message
  exit
end

def configure_server(path)
  FileUtils.mkdir_p(File.dirname(path))

  puts "Let's write the config."

  server_alias = prompt_required("Please, write the alias ", "Alias cannot be empty!")
  server_user = prompt_required("Write the username", "User cannot be empty!")
  server_name = prompt_required("Write name of server", "Server name cannot be empty!")
  server_host = prompt_required("Write the host IPv4 address", "Host cannot be empty!")

  puts "Write the port"
  server_port = gets.chomp.to_i

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

  File.write(path, config_content)
  puts " "
  puts "Done. Restart the programm."
  puts " "
end

def connect_to_server(server)
  host = server["host"]
  user = server["user"]
  port = server["port"]
  ssh_command = "ssh #{user}@#{host}"
  ssh_command = "ssh -p #{port} #{user}@#{host}" if port && port != 22

  if SSH_KEY_PATHS.any? { |path| Dir.glob(File.expand_path(path)).any? { |key_path| File.file?(key_path) } }
    system(ssh_command)
  else
    puts "Connection key not found!"
    puts "Please create a connection key for your server."
  end
end

def run_hyperssh
  path = config_path

  puts "HyperSSH v1.1"
  puts " "

  unless File.exist?(path)
    configure_server(path)
    return
  end

  puts "Config found"
  puts " "

  config = File.read(path)
  puts config
  puts " "

  servers = YAML.load_file(path)["servers"]

  loop do
    puts "Enter the server alias (or 'q' to quit)"
    server_alias = gets.chomp.strip
    break if server_alias == "q"

    selected_server = servers.find { |server| server["alias"] == server_alias }
    if selected_server
      connect_to_server(selected_server)
    else
      puts "Server not found!"
    end
  end
end

run_hyperssh
