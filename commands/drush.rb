require 'ruble'
require 'drush_fn.rb'
require 'multiple.rb'

Ruble::Logger.log_level = :trace

with_defaults :input => :none, :output => :output_to_console, :working_directory => :current_project do |bundle|
  command 'Execute PHP' do |cmd|
    cmd.output = ':discard'
    cmd.invoke do |context|
      drush_init()
    end
  end
end