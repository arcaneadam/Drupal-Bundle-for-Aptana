require 'java'


java_import org.eclipse.jface.wizard.WizardPage
java_import org.eclipse.swt.SWT
java_import org.eclipse.swt.layout.GridData
java_import org.eclipse.swt.layout.GridLayout
java_import org.eclipse.swt.widgets.Composite
java_import org.eclipse.swt.widgets.Label
java_import org.eclipse.swt.widgets.Text

module DrushSettingForm
  module UI
    class << self
      def testpage(pagename)
        wizard = CaptureEmployeeInfomrationWizard
        dialog = org.eclipse.jface.wizard.WizardDialog.new(shell, wizard.new())
        dialog.create()
        dialog.open()
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
  end

  class CaptureEmployeeInfomrationWizard < org.eclipse.jface.wizard.Wizard
    def addPages()
      personalInfoPage = PersonalInformationPage.new("Personal Information Page");
      addPage(personalInfoPage)
    end

    def performFinish()
      return false
    end
  end
end
