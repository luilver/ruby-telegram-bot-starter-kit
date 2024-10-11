# frozen_string_literal: true

namespace :tmp do
  desc 'Clear the temporary folder'
  task :clear do
    FileUtils.rm_rf('tmp')
  end
end
