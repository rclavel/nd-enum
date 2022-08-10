# frozen_string_literal: true

module ND::Enum::Configuration
  Configuration = Struct.new(:default_i18n_validation_mode, :default_i18n_scope)
  DEFAULT_CONFIGURATION = {
    default_i18n_validation_mode: :ignore,
    default_i18n_scope: :base,
  }

  def configuration
    @_configuration ||= Configuration.new(*DEFAULT_CONFIGURATION.values_at(*Configuration.members))
  end

  def configure
    yield(configuration)
  end
end
