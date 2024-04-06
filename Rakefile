# frozen_string_literal: true

require 'active_record'
require 'bundler/setup'
require 'fileutils'
require 'pg'
require 'rubygems'
require 'yaml'

namespace :db do
  desc 'Create the database'
  task :create do
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(connection_details.fetch('database'))
  end

  desc 'Drop the database'
  task :drop do
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.drop_database(connection_details.fetch('database'))
  end

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(connection_details)
    ActiveRecord::MigrationContext.new('db/migrate').migrate
  end
end

namespace :db do
  def admin_connection
    @admin_connection ||= connection_details.merge(
      {
        'database' => 'postgres',
        'schema_search_path' => 'public'
      }
    )
  end

  def connection_details
    @connection_details ||= YAML.safe_load(File.open('config/database.yml'))
  end
end

namespace :log do
  desc 'Clear the log folder'
  task :clear do
    FileUtils.rm_rf('log')
  end
end

namespace :tmp do
  desc 'Clear the temporary folder'
  task :clear do
    FileUtils.rm_rf('tmp')
  end
end
