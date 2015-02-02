require 'ostruct'

file_path = Rails.root.join("config", "site_configs.yml")

 if File.exists?(file_path)
   env = YAML.load_file(file_path).freeze["app_setup"]
   env.each{ |k, v| ENV[k] = v }
 end
