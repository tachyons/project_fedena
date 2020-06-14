require_relative '../config/boot.rb'

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.autoload_once_paths += %W( #{RAILS_ROOT}/lib )
  config.autoload_paths += Dir["#{RAILS_ROOT}/app/models/*"].find_all { |f| File.stat(f).directory? }

  config.reload_plugins = true if RAILS_ENV =="development"
  config.plugins = [:paperclip,:all]

  if (File.exist?('config/smtp_settings.yml'))
    SMTP_SETTINGS = YAML.load_file('config/smtp_settings.yml')[RAILS_ENV]
    if SMTP_SETTINGS      
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = SMTP_SETTINGS
    end
  end

end  

SMTP_SETTINGS = ActionMailer::Base.smtp_settings unless defined? SMTP_SETTINGS
