class FedenaSetting
  cattr_accessor :sms_settings_from_yml, :smtp_settings_from_yml, :company_settings_from_yml

  if File.exist?("#{Rails.root}/config/sms_settings.yml")
    @@sms_settings_from_yml = YAML.load_file(File.join(Rails.root, 'config', 'sms_settings.yml'))[RAILS_ENV]
  end
  if File.exist?("#{Rails.root}/config/smtp_settings.yml")
    @@smtp_settings_from_yml = YAML.load_file(File.join(Rails.root, 'config', 'smtp_settings.yml'))[RAILS_ENV]
  end
  if File.exist?("#{Rails.root}/config/company_details.yml")
    @@company_settings_from_yml = YAML.load_file(File.join(Rails.root, 'config', 'company_details.yml'))
  end

  def initialize; end

  def self.company_details
    FEDENA_SETTINGS
  end

  def self.smtp_settings
    SMTP_SETTINGS
  end
end
