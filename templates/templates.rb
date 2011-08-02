require 'ruble'
require 'functions.rb'
require 'drupal_ui.rb'

Ruble::Logger.log_level = :trace

template "Module Template" do |t|
  t.filetype = "*.module"
  t.replace_parameters = true
  t.invoke do |context|
    options = {}
    items = hooks_list()
    options[:items] = items
    options[:title] = "Select Hooks to Include"
    chosen = DrupalUI::UI.request_items(options)
    hooks = ''
    moduleName = ENV['TM_NEW_FILE_BASENAME']
    chosen.each do |hook|
      hook_s = hook.to_s
      out =<<END

/**
 * Implements hook_#{hook_s}()
 */
function #{moduleName}_#{hook_s}() {

}
END
      hooks << out
    end
    ENV['hooks'] = hooks
    raw_contents = IO.read("#{ENV['TM_BUNDLE_SUPPORT']}/../templates/template.module")
    raw_contents.gsub(/\$\{([^}]*)\}/) {|match| ENV[match[2..-2]] }
 end
end

template "Install Template" do |t|
  t.filetype = "*.install"
  t.replace_parameters = true
  t.input = :none
  t.output = :none
  t.invoke do |context|
    options = {}
    items = ['install', 'uninstall', 'schema']
    options[:items] = items
    options[:title] = "Select Hooks to Include"
    chosen = DrupalUI::UI.request_items(options)
    hooks = ''
    moduleName = ENV['TM_NEW_FILE_BASENAME']
    chosen.each do |hook|
      hook_s = hook.to_s
      out =<<END

/**
 * Implements hook_#{hook_s}()
 */
function #{moduleName}_#{hook_s}() {

}
END
      hooks << out
    end
    ENV['hooks'] = hooks
    raw_contents = IO.read("#{ENV['TM_BUNDLE_SUPPORT']}/../templates/template.install")
    raw_contents.gsub(/\$\{([^}]*)\}/) {|match| ENV[match[2..-2]] }
 end
end

template "Info Template" do |t|
  t.filetype = "*.info"
  t.replace_parameters = true
  t.invoke do |context|
    mname = {}
    mname[:title] = "Module Name"
    mname[:prompt] = "Enter the Module name"
    ENV['moduleName'] = Ruble::UI.request_string(mname)
    mdesc = {}
    mdesc[:title] = "Module Description"
    mdesc[:prompt] = "Enter the Module description"
    ENV['moduleDesc'] = Ruble::UI.request_string(mdesc)
    mpack = {}
    mpack[:title] = "Module Package"
    mpack[:prompt] = "Enter the Module Package"
    ENV['modulePack'] = Ruble::UI.request_string(mpack)
    options = {}
    items = ['6.x', '7.x']
    options[:items] = items
    options[:title] = "Select Core Version"
    options[:default] = '7.x'
    ENV['core'] = Ruble::UI.request_item(options)
    deps = ''
    mdep = {}
    mdep[:title] = "Module Dependencies"
    mdep[:prompt] = "Enter the Module dependencies(seperated by comma)"
    depends = Ruble::UI.request_string(mdep)
    depends.split(',').each do |dep|
      if !dep.to_s.strip.empty?
        deps << "dependencies[] = " + dep.to_s.strip + "\n"
      end
    end
    ENV['dependencies'] = deps
    raw_contents = IO.read("#{ENV['TM_BUNDLE_SUPPORT']}/../templates/template.info")
    raw_contents.gsub(/\$\{([^}]*)\}/) {|match| ENV[match[2..-2]] }
 end
end