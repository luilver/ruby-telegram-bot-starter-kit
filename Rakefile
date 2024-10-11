# frozen_string_literal: true

require 'bundler/setup'
require 'fileutils'
require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'rubygems'

RSpec::Core::RakeTask.new(:spec)

Rake.add_rakelib 'lib/tasks'

RuboCop::RakeTask.new(:rubocop)

task default: %i[rubocop spec]
