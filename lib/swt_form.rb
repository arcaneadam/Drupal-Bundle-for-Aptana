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
      def testpage()
        wizard = CaptureEmployeeInfomrationWizard
        @dialog = org.eclipse.jface.wizard.WizardDialog.new(shell, wizard.new())
        @dialog.create()
        @dialog.open()
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

  class PersonalInformationPage < org.eclipse.jface.wizard.WizardPage
    @firstNameText
    @secondNameText
    def initialize(pageName)
      super(pageName)
      setTitle("Personal Information")
      setDescription("Please enter your personal information")
    end

    def createControl(parent)
      composite = org.eclipse.swt.widgets.Composite.new(parent, org.eclipse.swt.SWT::NONE)
      layout = org.eclipse.swt.layout.GridLayout.new()
      layout.numColumns = 2
      composite.setLayout(layout)
      setControl(composite)
      org.eclipse.swt.widgets.Label.new(composite, org.eclipse.swt.SWT::NONE).setText("First Name")
      @firstNameText = org.eclipse.swt.widgets.Text.new(composite, org.eclipse.swt.SWT::NONE)
      org.eclipse.swt.widgets.Label.new(composite, org.eclipse.swt.SWT::NONE).setText("Last Name")
      @secondNameText = org.eclipse.swt.widgets.Text.new(composite, org.eclipse.swt.SWT::NONE)
    end
    def getfirst
      @firstNameText.getText()
    end
    def getlast
      @secondNameText.getText()
    end
  end

  class CaptureEmployeeInfomrationWizard < org.eclipse.jface.wizard.Wizard
    @personalInfoPage
    def addPages()
      @personalInfoPage = PersonalInformationPage.new("Personal Information Page");
      addPage(@personalInfoPage)
    end

    def performFinish()
      CONSOLE.puts @personalInfoPage.getfirst
      return true
    end
  end
end
