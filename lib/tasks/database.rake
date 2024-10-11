require 'bundler'
require './config/environment'

namespace :db do
  desc 'create your database'
  task :create do
    Bundler.require

    env = ENV.fetch('RACK_ENV')
    puts("== Create #{env} database ==")
    FileUtils.touch("db/#{env}.db")
  end

  desc 'drop your database'
  task :drop do
    Bundler.require

    env = ENV.fetch('RACK_ENV')
    puts("== Create #{env} database ==")
    FileUtils.rm_rf("db/#{env}.db")
  end

  desc 'migrate your database'
  task migrate: [:environment] do
    Bundler.require

    ActiveRecord::MigrationContext.new('db/migrate').migrate
  end

  desc 'prepare your database'
  task :prepare do
    Rake::Task['db:drop'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
  end

  desc 'Seed the database'
  task :seed do
    load 'db/seeds.rb'
  end
end
