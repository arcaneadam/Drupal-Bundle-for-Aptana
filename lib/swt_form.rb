require 'java'
require 'ruble'

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
      def settingsPage(settings = Hash.new)
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
      layout.numColumns = 2
      composite.setLayout(layout)
      org.eclipse.swt.widgets.Label.new(composite, org.eclipse.swt.SWT::NONE).setText("Path to Drush")
      @drushPath = org.eclipse.swt.widgets.Text.new(composite, org.eclipse.swt.SWT::SINGLE)
      @alwaysYes = org.eclipse.swt.widgets.Button.new(composite, org.eclipse.swt.SWT::CHECK)
      @alwaysYes.setText("Always answer yes")
      org.eclipse.swt.widgets.Label.new(composite, org.eclipse.swt.SWT::NONE).setText("(Passes Drush the argument '-y')")
      setControl(composite)
    end
    def getDrushPath
      @drushPath.getText()
    end
    def getYes
      @alwaysYes.getSelection()
    end
  end

  class DrushSiteSettings < org.eclipse.jface.wizard.Wizard
    @settingsPage
    @defaults
    def addPages()
      @settingsPage = SiteSettingsPage.new("Site Settings");
      @settingsPage.setDefaults(@defaults)
      addPage(@settingsPage)
    end
    def performFinish
      self.saveResults
      true
    end
    def saveResults
      @data = Hash['path' => @settingsPage.getDrushPath,'yes' => @settingsPage.getYes]
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
