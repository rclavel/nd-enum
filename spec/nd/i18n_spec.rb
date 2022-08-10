# frozen_string_literal: true

RSpec.describe ND::Enum::I18n do
  describe 'translate' do
    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(role: %w(user admin))
      end
    }

    it 'translate with default scope' do
      I18n.expects(:t).with(:user, scope: 'users.role.base')
      model::Role.t(:user)
    end

    it 'translate with custom scope' do
      I18n.expects(:t).with(:user, scope: 'users.role.custom')
      model::Role.t(:user, :custom)
    end

    it 'is aliased with translate method' do
      I18n.expects(:t).with(:user, scope: 'users.role.base')
      model::Role.translate(:user)
    end

    it 'use the default scope from configuration' do
      model::Role.stubs(:configuration).returns(mock.tap { |m| m.stubs(:default_i18n_scope).returns(:foobar) })
      I18n.expects(:t).with(:user, scope: 'users.role.foobar')
      model::Role.t(:user)
    end
  end

  describe 'validation' do
    it 'does not validate by default' do
      ND::Enum::I18n.expects(:log_missing_keys).never

      Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(title: %w(doctor professor), model_name: 'User')
      end
    end

    it 'logs missing keys' do
      ND::Enum::I18n.expects(:log_missing_keys).with do |_, scopes, missing_keys_by_locale|
        expect(scopes).to eq(%i(base))
        expect(missing_keys_by_locale).to eq(en: %w(users.title.base.doctor users.title.base.professor))
      end.once

      Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(title: %w(doctor professor), i18n: { validate: :log }, model_name: 'User')
      end
    end


    it 'raises if keys are missing' do
      ND::Enum::I18n.expects(:log_missing_keys).with do |_, scopes, missing_keys_by_locale|
        expect(scopes).to eq(%i(base))
        expect(missing_keys_by_locale).to eq(en: %w(users.title.base.doctor users.title.base.professor))
      end.once

      expect {
        Class.new(ActiveRecord::Base) do
          self.table_name = 'users'
          nd_enum(title: %w(doctor professor), i18n: { validate: :enforce }, model_name: 'User')
        end
      }.to raise_error(ND::Enum::MissingTranslationError)
    end

    it 'can log missing keys by default' do
      ND::Enum::I18n.stubs(:configuration).returns(mock.tap { |m| m.stubs(:default_i18n_validation_mode).returns(:log) })

      ND::Enum::I18n.expects(:log_missing_keys).with do |_, scopes, missing_keys_by_locale|
        expect(scopes).to eq(%i(base))
        expect(missing_keys_by_locale).to eq(en: %w(users.title.base.doctor users.title.base.professor))
      end.once

      Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(title: %w(doctor professor), model_name: 'User')
      end
    end

    it 'can raise for missing keys by default' do
      ND::Enum::I18n.stubs(:configuration).returns(mock.tap { |m| m.stubs(:default_i18n_validation_mode).returns(:enforce) })

      ND::Enum::I18n.expects(:log_missing_keys).with do |_, scopes, missing_keys_by_locale|
        expect(scopes).to eq(%i(base))
        expect(missing_keys_by_locale).to eq(en: %w(users.title.base.doctor users.title.base.professor))
      end.once

      expect {
        Class.new(ActiveRecord::Base) do
          self.table_name = 'users'
          nd_enum(title: %w(doctor professor), model_name: 'User')
        end
      }.to raise_error(ND::Enum::MissingTranslationError)
    end
  end
end
