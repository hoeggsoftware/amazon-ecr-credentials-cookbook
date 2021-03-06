require 'sshkey'
require 'droplet_kit'

module Helpers
  # Configures and removes key for digital ocean
  class DOConnection
    KEY_FILE_PATH = '/tmp/key_file'

    def initialize(
      access_token:     ENV['DIGITALOCEAN_ACCESS_TOKEN'],
      config_file_path: '/home/jenkins/.ssh/config'
    )
      puts 'Connecting to Digital Ocean'
      @client = DropletKit::Client.new(access_token: access_token)
      puts 'Generating new RSA Key'
      @rsa_key = SSHKey.generate
      @config_file_path = config_file_path
      @file_length      = File.size(config_file_path)
    end

    attr_reader :client, :config_file_path, :rsa_key, :file_length

    def public_key
      @pub ||= rsa_key.ssh_public_key
    end

    def private_key
      @private_key ||= rsa_key.private_key
    end

    def register_do_key!
      puts 'Registering key with Digital Ocean'
      unless client.ssh_keys.find(id: id)
        @do_key = client.ssh_keys.create(
          DropletKit::SSHKey.new(
            name: 'kitchen_testing', public_key: public_key
          )
        )
      end
      ENV['DIGITALOCEAN_SSH_KEY_IDS'] = id.to_s
      setup_keyfile!
    end

    def id
      @do_key ? @do_key.id : nil
    end

    def unregister_do_key!
      puts 'Removing key from Digital Ocean registration'
      client.ssh_keys.delete(id: id)
      cleanup_keyfile!
    end

    def setup_keyfile!
      cleanup_keyfile! if File.exist?(KEY_FILE_PATH)
      puts "Putting private key in #{KEY_FILE_PATH}"
      File.open(KEY_FILE_PATH, 'w+') { |f| f.write(private_key) }
      File.chmod(0400, KEY_FILE_PATH)
      File.open(config_file_path, 'a') do |f|
        f.puts "Identityfile #{KEY_FILE_PATH}"
      end
    end

    def cleanup_keyfile!
      puts "Removing private key from #{KEY_FILE_PATH}"
      File.delete(KEY_FILE_PATH)
      File.truncate(config_file_path, file_length)
    end
  end
end
