# frozen_string_literal: true

RSpec.describe ND::Enum::Configuration do
  describe 'configuration' do
    it 'has default configuration' do
      expect(ND::Enum.configuration.to_h).to eq(
        default_i18n_scope: :base,
        default_i18n_validation_mode: :ignore,
      )
    end

    it 'allows to configure' do
      ND::Enum.configure do |c|
        c.default_i18n_scope = :foobar
        c.default_i18n_validation_mode = :enforce
      end

      expect(ND::Enum.configuration.to_h).to eq(
        default_i18n_scope: :foobar,
        default_i18n_validation_mode: :enforce,
      )

      ND::Enum.configure do |c|
        c.default_i18n_scope = :base
        c.default_i18n_validation_mode = :ignore
      end
    end
  end
end
