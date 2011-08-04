require 'ruble'
require 'drush_fn.rb'
require 'drupal_ui.rb'
require 'swt_form.rb'
require 'java'
require 'YAML'



Ruble::Logger.log_level = :trace

with_defaults :input => :none, :output => :output_to_console, :working_directory => :current_project do |bundle|
  command 'Execute PHP' do |cmd|
    cmd.key_binding = "CONTROL+D"
    cmd.output = ':discard'
    cmd.invoke do |context|
      result = DrushSettingForm::UI.settingsPage()
      CONSOLE.puts YAML.dump(result)
      return nil
      drush = drush_init()
      if !drush
        return nil
      end
      options = {}
      options[:title] = "Enter PHP Code"
      options[:prompt] = "DO NOT USE <?php ?> tags when entering your code"
      code = DrupalUI::UI.request_string_multi(options)
      if !code || code.empty?
      return
      end
      msg = {}
      msg[:summary] = code
      Ruble::UI.simple_notification(msg)
    end
  end
end
