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

def drush_write_yaml(obj)
  File.new("#{File.dirname(ENV['TM_BUNDLE_SUPPORT'])}/settings/settings.yml",  File::CREAT|File::TRUNC|File::RDWR, 0644) do |file|
    (1..10).each do |index|
      file.puts YAML::dump(obj)
      file.puts ""
    end
  end
end

def drush_get_yaml()
  settings = []
  $/="\n\n"
  file = "#{File.dirname(ENV['TM_BUNDLE_SUPPORT'])}/settings/settings.yml"
  if File.exists?(file)
    File.new(file,  File::CREAT|File::TRUNC|File::RDWR, 0644).each do |object|
      settings << YAML::load(object)
    end
  end
  return settings
end

def drush_init()
  settings = drush_get_yaml()
  dir = ENV['TM_PROJECT_DIRECTORY']
  sites = scan_sites_dir(dir)
  if sites.length == 0
    msg = "The project you are working on does not appear to be a Drupal Install. Please run this command from a Drupal project"
    alert = Ruble::UI.alert(:error, 'No Drupal Install to run from', msg)
    return 0
  elsif sites.length == 1
    site = sites[0]
  else
    options = {}
    options[:items] = sites
    options[:title] = "Select Site Settings to use"
    site = Ruble::UI.request_item(options)
  end
  settings[site.hash] = site
  drush_write_yaml(settings)
end