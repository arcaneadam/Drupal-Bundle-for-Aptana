require 'java'
require 'ruble'
require 'drush_fn.rb'

java_import org.eclipse.jface.wizard.WizardPage
java_import org.eclipse.swt.SWT
java_import org.eclipse.swt.layout.GridData
java_import org.eclipse.swt.layout.GridLayout
java_import org.eclipse.swt.widgets.Composite
java_import org.eclipse.swt.widgets.Label
java_import org.eclipse.swt.widgets.Text

module DrushSettingForm
  @dialog
  # A class to make it easy to generate UIJobs. Takes a block which is 
  # then called as the body of runInUIThread
  class UIJob < org.eclipse.ui.progress.UIJob
    def initialize(name, &blk)
      super(name)
      @block = blk
    end
    
    def runInUIThread(monitor)
      @block.call(monitor)
      return org.eclipse.core.runtime.Status::OK_STATUS
    end
  end
  
  module UI
    class << self
      def settingsPage(project = '')
        drush = drush_get_yaml()
        if project.empty?
          settings = Hash['path' => drush['path'],
                          'yes' => drush['yes'],
                          'arg' => drush['args'],
                          'global' => true]
        elsif drush.has_key?(project.hash)
          settings = drush[project.hash]
        else
          settings = Hash['path' => '',
                          'yes' => FALSE,
                          'arg' => '']
          if drush.has_key?('path') 
            settings['path'] = drush['path'];
          end
          if drush.has_key?('yes') 
            settings['yes'] = drush['yes'];
          end
        end
        wizard = DrushSiteSettings.new
        wizard.setDefaults(settings)
        @dialog = DrushSiteSettingsDialog.new(shell, wizard)
        @dialog.create()
        return_value = nil
        return_value = @dialog.value if @dialog.open == org.eclipse.jface.window.Window::OK

        if return_value == nil then
          block_given? ? raise(SystemExit) : nil
        else
          block_given? ? yield(return_value) : return_value
        end
      end

      private

      def default_buttons(user_options = Hash.new)
        options = Hash.new
        options['button1'] = user_options[:button1] || "OK"
        options['button2'] = user_options[:button2] || "Cancel"
        options
      end

      def in_ui_thread?
        !org.eclipse.swt.widgets.Display.current.nil?
      end

      def display
        org.eclipse.swt.widgets.Display.current || org.eclipse.swt.widgets.Display.default
      end

      def shell
        display.active_shell || org.eclipse.swt.widgets.Shell.new(display)
      end
    end
  end

  class SiteSettingsPage < org.eclipse.jface.wizard.WizardPage
    @drushPath
    @alwaysYes
    @siteSelection
    @defaults
    def initialize(pageName)
      super(pageName)
      setTitle("Drush Project Settings")
      setDescription("Drush settings for the current Project")
    end
    def setDefaults(defaults)
      @defaults = defaults
    end
    def createControl(parent)

      composite = org.eclipse.swt.widgets.Composite.new(parent, org.eclipse.swt.SWT::NONE)
      layout = org.eclipse.swt.layout.GridLayout.new()
      layout.numColumns = 3
      composite.setLayout(layout)
      
      pathLabel = org.eclipse.swt.widgets.Label.new(composite, org.eclipse.swt.SWT::NONE)
      pathLabel.setText("Path to Drush")
      
      font = pathLabel.getFont()
      fontStyles = font.getFontData()
      fontStyle = fontStyles[0]
      fontBold = fontStyle
      fontBold.setStyle(org.eclipse.swt.SWT::BOLD)
      
      @drushPath = org.eclipse.swt.widgets.Text.new(composite, org.eclipse.swt.SWT::SINGLE)
      gridData = org.eclipse.swt.layout.GridData.new()
      gridData.horizontalAlignment = org.eclipse.swt.SWT::FILL
      gridData.grabExcessHorizontalSpace = true
      @drushPath.setLayoutData(gridData)
      @drushPath.setText(@defaults['path'])
      
      pathPicker = org.eclipse.swt.widgets.Button.new(composite, org.eclipse.swt.SWT::PUSH | org.eclipse.swt.SWT::BORDER)
      pathPicker.setText('Browse...')
      fileDialog = FileListener.new()
      fileDialog.setField(@drushPath)
      pathPicker.addSelectionListener(fileDialog)
      
      @alwaysYes = org.eclipse.swt.widgets.Button.new(composite, org.eclipse.swt.SWT::CHECK)
      @alwaysYes.setText("Always answer yes")
      if @defaults.has_key?('yes') and @defaults['yes']
        @alwaysYes.setSelection(TRUE)
      end
      
      gridData = org.eclipse.swt.layout.GridData.new()
      gridData.horizontalSpan = 2
      yesLabel = org.eclipse.swt.widgets.Label.new(composite, org.eclipse.swt.SWT::NONE)
      yesLabel.setText("(Passes Drush the argument '-y')")
      yesLabel.setLayoutData(gridData)
      
      if !@defaults.has_key?('global')
        selectLabel = org.eclipse.swt.widgets.Label.new(composite, org.eclipse.swt.SWT::HORIZONTAL)
        selectLabel.setText("Select the site to run Drush from if other then 'default'")
        gridData = org.eclipse.swt.layout.GridData.new()
        gridData.horizontalSpan = 3
        gridData.horizontalAlignment = org.eclipse.swt.SWT::FILL
        gridData.grabExcessHorizontalSpace = true
        gridData.verticalAlignment = org.eclipse.swt.SWT::FILL
        selectLabel.setLayoutData(gridData)
        selectLabel.setFont(org.eclipse.swt.graphics.Font.new(parent.getDisplay(), fontBold))

        @siteSelection = org.eclipse.swt.widgets.List.new(composite, org.eclipse.swt.SWT::SINGLE | org.eclipse.swt.SWT::COLOR_WIDGET_BORDER)
        gridData = org.eclipse.swt.layout.GridData.new()
        gridData.horizontalSpan = 3
        gridData.horizontalAlignment = org.eclipse.swt.SWT::FILL
        gridData.grabExcessHorizontalSpace = true
        gridData.heightHint = 100
        @siteSelection.setLayoutData(gridData)
        sites = scan_sites_dir(ENV['TM_PROJECT_DIRECTORY'])
        sites.each do |site|
          @siteSelection.add(site.to_s)
        end
      end
      setControl(composite)
    end
    def getDrushPath
      @drushPath.getText()
    end
    def getYes
      @alwaysYes.getSelection()
    end
    def getSite
      @siteSelection.getSelection()
    end
    class FileListener < org.eclipse.swt.events.SelectionAdapter
      @text
      def setField(text)
        @text = text
      end
      def widgetSelected(e)
        CONSOLE.puts YAML::dump(e)
        dir = @text.getText()
        path_opt = {}
        path_opt[:title] = "Please set the path to your Drush instance"
        path_opt[:only_directories] = TRUE
        path_opt[:directory] = dir.empty? ? ENV['TM_PROJECT_DIRECTORY'] : dir
        path = Ruble::UI.request_file(path_opt)
        @text.setText(path)
      end
    end
  end

  class DrushSiteSettings < org.eclipse.jface.wizard.Wizard
    @settingsPage
    @defaults
    def addPages()
      @settingsPage = SiteSettingsPage.new("Site Settings")
      @settingsPage.setDefaults(@defaults)
      addPage(@settingsPage)
    end
    def performFinish
      self.saveResults
      true
    end
    def saveResults
      @data = Hash.new
      @data['path'] = @settingsPage.getDrushPath
      @data['yes'] = @settingsPage.getYes
      if !@defaults.has_key?('global')
        @data['site'] = @settingsPage.getSite
      end
    end
    def setDefaults(defaults)
      @defaults = defaults
    end
    def getData
      @data
    end
  end
  
  class DrushSiteSettingsDialog < org.eclipse.jface.wizard.WizardDialog
    def value
      getWizard().getData
    end
  end
end
