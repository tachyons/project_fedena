if File.exist?(File.expand_path('./config/locale_settings.yml'))
  locale_settings = YAML.safe_load(File.open(File.expand_path('./config/locale_settings.yml')), [Symbol])
  AVAILABLE_LANGUAGES = !locale_settings['available'].empty? ? locale_settings['available'] : { en: 'English' }
  DEFAULT_LANGUAGE = AVAILABLE_LANGUAGES.include?(locale_settings['default']) ? locale_settings['default'] : AVAILABLE_LANGUAGES.keys[0].to_s
  AVAILABLE_LANGUAGE_CODES = locale_settings['available'].keys.map(&:to_s)
  LANGUAGE_CODES_MAP = locale_settings['fallbacks']
  RTL_LANGUAGES = locale_settings['rtl']
else
  AVAILABLE_LANGUAGES = { en: 'English' }
  DEFAULT_LANGUAGE = 'en'
  AVAILABLE_LANGUAGE_CODES = ['en']
  LANGUAGE_CODES_MAP = {}
  RTL_LANGUAGES = []
end
