require 'ruble'
require 'drush_fn.rb'
require 'drupal_ui.rb'
require 'swt_form.rb'
require 'java'
require 'YAML'



Ruble::Logger.log_level = :trace

with_defaults :input => :none, :output => :output_to_console, :working_directory => :current_project do |bundle|
  command 'Execute PHP' do |cmd|
    cmd.invoke do |context|
      drush = drush_init()
      if !drush
        return nil
      end
      options = {}
      options[:title] = "Enter PHP Code"
      options[:prompt] = "DO NOT USE <?php ?> tags when entering your code"
      code = DrupalUI::UI.request_string_multi(options)
      if !code || code.empty?
        
      end
      msg = {}
      msg[:summary] = code
      Ruble::UI.simple_notification(msg)
    end
  end
  command 'Global Drush Settings' do |cmd|
    cmd.key_binding = "ALT+D"
    cmd.key_binding.mac = "CTRL+D"
    cmd.invoke do |context|
      result = DrushSettingForm::UI.settingsPage()
      if result
        drush_write_yaml(result);
      end
    end
  end
  command 'Project Drush Settings' do |cmd|
    cmd.invoke do |context|
      result = DrushSettingForm::UI.settingsPage(ENV["TM_PROJECT_NAME"])
      if result
        drush_write_yaml(result);
      end
    end
  end
end

