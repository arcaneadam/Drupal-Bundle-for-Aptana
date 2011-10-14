require 'ruble'
require 'YAML'
Ruble::Logger.log_level = :trace


def scan_sites_dir(dir)
  sites = []
  sites_dir = dir + '/sites'
  x = 0
  if File.exists?(sites_dir)
    contains = Dir.new(sites_dir).entries
    for i in contains
      if i != '.' || i != '..'
        settings = sites_dir + '/' + i + '/settings.php'
        if File.exists?(settings)
          sites[x] = i
          x += 1
        end
      end
    end
  end
  return sites
end

def drush_write_yaml(obj, hash = 'global')
  settings = drush_get_yaml()
  settings[hash] = obj
  doc = YAML::dump(settings)
  filename = "#{ENV['TM_BUNDLE_SUPPORT']}/../drupal.ruble.settings.yml"
  File.open(filename, 'w', 0755) {|f| f.write(doc) }
end
def drush_get_yaml(hash = 'global')
  global = Hash['path' => '',
                'yes' => FALSE,
                'arg' => '']
  settings = Hash[]
  $/="\n\n"
  file = "#{ENV['TM_BUNDLE_SUPPORT']}/../drupal.ruble.settings.yml"
  if File.exists?(file)
    object = File.new(file, File::RDONLY|File::CREAT, 0755).read
    settings = YAML::load(object)
  else
    settings = Hash['global' => global]
  end
  if !settings.has_key?(hash)
    settings[hash] = global
  end
  return settings
end

def drush_init(site = 'global')
  # Check first thing that we are running from a Drupal install
  dir = ENV['TM_PROJECT_DIRECTORY']
  sites = scan_sites_dir(dir)
  if sites.length == 0
    msg = "The project you are working on does not appear to be a Drupal Install. Please run this command from a Drupal project"
    alert = Ruble::UI.alert(:error, 'No Drupal Install to run from', msg)
    return nil
  end
  
  settings = drush_get_yaml(site)
  if settings.has_key?(site)
    drush = settings[site]
  elsif settings.has_key?('global')
    drush = settings['global']
  end
  while !drush['path'] || drush['path'].empty?
    msg = {}
    msg[:summary] = "You must configure your drush settings before you can use the drush commands."
    Ruble::UI.simple_notification(msg)
    drush = drush_settings(site)
  end
  # We need to also offer a return here in case the user cancels out of the dialog w/o setting the path
  if !drush['path'] || drush['path'].empty?
    return nil
  end
  
  while !drush.has_key?('site') || drush['site'].empty?
    options = {}
    options[:items] = sites
    options[:title] = "Select Site to use. (settings.php)"
    drush['site'] = Ruble::UI.request_item(options)
  end
  
  if !drush['site'] || drush['site'].empty?
    return nil
  end
  
  return drush
end

def drush_exec(drush, cmd)
  drex = drush['path'] + '/drush'
  out = ``
end

def drush_settings(site = 'global')
  result = DrushSettingForm::UI.settingsPage(site)
  if result
    drush_write_yaml(result, site);
    return result
  end
end
