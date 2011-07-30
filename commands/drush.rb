require 'ruble'
require 'drush_fn.rb'
require 'multiple.rb'
require 'java'

Ruble::Logger.log_level = :trace

with_defaults :input => :none, :output => :output_to_console, :working_directory => :current_project do |bundle|
  command 'Execute PHP' do |cmd|
    cmd.key_binding = "CONTROL+D"
    cmd.output = ':discard'
    cmd.invoke do |context|
      options = {}
      options[:title] = "Enter PHP Code"
      code = org.eclipse.jface.dialogs.InputDialog
      CONSOLE.puts code
    end
  end
end