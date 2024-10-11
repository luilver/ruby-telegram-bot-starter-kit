# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'app'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
require 'rubygems'
Bundler.require :default, ENV.fetch('RACK_ENV', 'development')

require 'active_record'
Dir[File.expand_path('../app/**/*.rb', __dir__)].each { |f| require f }

begin
  yaml = 'config/database.yml'
  if File.exist?(yaml)
    require 'active_support/core_ext/hash'
    require 'erb'
    config = HashWithIndifferentAccess.new(
      YAML.safe_load(ERB.new(File.read(yaml)).result, aliases: true)
    )
  elsif ENV['DATABASE']
    nil
  else
    raise "Could not load database configuration. No such file - #{yaml}"
  end
rescue Psych::SyntaxError => e
  raise 'YAML syntax error occurred while parsing config/database. ' \
        'Please note that YAML must be consistently indented using spaces. ' \
        "Tabs are not allowed. Error: #{e.message}"
end

env = ENV['RACK_ENV'] || 'development'
adapter = config[env][:adapter]
database = config[env][:database]
db_options = { adapter:, database: }
config[:connection] = ActiveRecord::Base.establish_connection(db_options)
