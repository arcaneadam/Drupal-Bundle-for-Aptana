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

def drush_write_yaml(obj, bundle = nil)
  doc = YAML::dump(obj)
  filename = "#{ENV['TM_BUNDLE_SUPPORT']}/../drupal.ruble.settings.yml"
  File.open(filename, 'w', 0755) {|f| f.write(doc) }
end

def drush_get_yaml(bundle = nil)
  settings = {}
  $/="\n\n"
  file = "#{ENV['TM_BUNDLE_SUPPORT']}/../drupal.ruble.settings.yml"
  if File.exists?(file)
    object = File.new(file, File::RDONLY|File::CREAT, 0755).read
    settings = YAML::load(object)
  end
  return settings
end

def drush_init()
  drush = drush_get_yaml(1)
  if !drush[:path] || drush[:path].empty?
    path_opt = {}
    path_opt[:title] = "Please set the path to your Drush instance"
    path_opt[:only_directories] = TRUE
    path_opt[:directory] ="~"
    path = Ruble::UI.request_file(path_opt)
    CONSOLE.puts path
    if !path || path.empty?
      msg = "You must select a valid Drush location in order to run Drush commands"
      alert = Ruble::UI.alert(:error, "Drush path needed in order to run Drush commands", msg)
    else
      drush[:path] = path
      drush_write_yaml(drush, 1)
    end
  end
  dir = ENV['TM_PROJECT_DIRECTORY']
  sites = scan_sites_dir(dir)
  if sites.length == 0
    msg = "The project you are working on does not appear to be a Drupal Install. Please run this command from a Drupal project"
    alert = Ruble::UI.alert(:error, 'No Drupal Install to run from', msg)
    return nil
  elsif sites.length == 1
    site = sites[0]
  else
    options = {}
    options[:items] = sites
    options[:title] = "Select Site Settings to use"
    site = Ruble::UI.request_item(options)
  end
  project_hash = ENV['TM_PROJECT_NAME'].hash
  drush[project_hash] = {}
  drush[project_hash][:site] = site
  drush_write_yaml(drush)
  return drush
end

def drush_exec(drush, cmd)
  drex = drush[:path] + '/drush'
  out = ``
end