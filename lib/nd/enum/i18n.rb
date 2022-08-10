# frozen_string_literal: true

module ND::Enum::I18n
  class << self
    # TODO: Transform into a nd_enum
    module Mode
      LOG = 'log'
      ENFORCE = 'enforce'
      IGNORE = 'ignore'

      def self.all
        [LOG, ENFORCE, IGNORE]
      end
    end

    def validate!(options)
      mode = get_mode_from_options(options)
      return if mode == Mode::IGNORE

      i18n_scope = build_i18n_scope(options)
      scopes = get_scopes_from_translations(i18n_scope)
      missing_keys_by_locale = get_missing_keys_by_locale(options, i18n_scope, scopes)

      log_missing_keys(options, scopes, missing_keys_by_locale)

      if mode == Mode::ENFORCE && missing_keys_by_locale.values.any?(&:present?)
        raise ND::Enum::MissingTranslationError
      end
    end

    private

    def get_mode_from_options(options)
      case options.dig(:i18n, :validate)
      when 'log', :log then Mode::LOG
      when 'enforce', :enforce then Mode::ENFORCE
      else
        default_mode = configuration.default_i18n_validation_mode&.to_s
        Mode.all.include?(default_mode) ? default_mode : Mode::IGNORE
      end
    end

    def build_i18n_scope(options)
      "#{options[:model].table_name}.#{options[:attribute]}"
    end

    def get_scopes_from_translations(i18n_scope)
      scopes = %i(base)

      I18n.available_locales.each do |locale|
        configuration = I18n.t(i18n_scope, locale: locale, default: {})
        configuration.each_key do |scope|
          scopes << scope.to_sym unless scopes.include?(scope.to_sym)
        end
      end

      scopes
    end

    def get_missing_keys_by_locale(options, i18n_scope, scopes)
      I18n.available_locales.each_with_object({}) do |locale, missing_keys_by_locale|
        missing_keys = []

        scopes.each do |scope|
          options[:values].each do |value|
            value_i18n_scope = "#{i18n_scope}.#{scope}.#{value}"
            next if I18n.exists?(value_i18n_scope, locale: locale)

            missing_keys << value_i18n_scope
          end
        end

        missing_keys_by_locale[locale] = missing_keys
      end
    end

    def log_missing_keys(options, scopes, missing_keys_by_locale)
      prefix = "ND::Enum: #{options[:model_name]}##{options[:attribute]}"
      logger.info("#{prefix} scopes=#{scopes}")

      missing_keys_by_locale.each do |locale, missing_keys|
        logger.info("#{prefix} locale=#{locale} missing_keys=#{missing_keys}")
      end
    end

    def logger
      @_logger ||= Logger.new(STDOUT)
    end

    def configuration
      ND::Enum.configuration
    end
  end
end
