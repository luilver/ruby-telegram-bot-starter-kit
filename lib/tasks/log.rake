# frozen_string_literal: true

namespace :log do
  desc 'Clear the log folder'
  task :clear do
    FileUtils.rm_rf('log')
  end
end
