require 'ruble'
require 'functions.rb'
require 'multiple.rb'

Ruble::Logger.log_level = :trace

with_defaults :input => :none, :output => :output_to_console, :working_directory => :current_project do |bundle|
  command 'Execute PHP' do |cmd|
    cmd.output = ':discard'
    cmd.invoke do |context|    
      sites = scan_sites_dir(ENV['TM_PROJECT_DIRECTORY'])
      if sites.length == 0
        msg = "The project you are working on does not appear to be a Drupal Install. Please run this command from a Drupal project"
        alert = Ruble::UI.alert(:error, 'No Drupal Install to run from', msg)
        return
      elsif sites.length == 1
        site = sites[0]
      else
        options = {}
        options[:items] = sites
        options[:title] = "Select Site Settings to use"
        site = Ruble::UI.request_item(options)
      end
      opts = {}
      opts[:title] = "Enter PHP Code to execute"
      opts[:prompt] = "Do not inculde the <?php ?> tags!"
      code = RubleM::UI.request_string_multi(opts)
      alert = Ruble::UI.alert(:info, 'Code Returned', code)
    end
  end
end