# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
end

class User < ApplicationRecord
  self.table_name = 'users'
  nd_enum(role: %w(user admin))
end

class DummyDb < ApplicationRecord
  nd_enum(role: %w(user admin), db: true)
end

class DummyPrefix < ApplicationRecord
  nd_enum(role: %w(user admin), db: { prefix: true })
end

class DummyCustomPrefix < ApplicationRecord
  nd_enum(role: %w(user admin), db: { prefix: 'foobar' })
end

RSpec.describe ND::Enum do
  describe 'constants' do
    it 'defines a module for the enum' do
      expect(User.constants).to include(:Role)
      expect(User::Role.class).to be(Module)
    end

    it 'defines a constant for each enum value' do
      expect(User::Role.constants.sort).to eq(%i(ADMIN USER))
      expect(User::Role::USER).to eq('user')
      expect(User::Role::ADMIN).to eq('admin')
    end
  end

  describe 'enumerable' do
    it '#all' do
      expect(User::Role.all).to eq(%w(user admin))
    end

    it '#size' do
      expect(User::Role.size).to eq(2)
    end

    it '#length' do
      expect(User::Role.length).to eq(2)
    end

    it '#[] with integer' do
      expect(User::Role[0]).to eq('user')
      expect(User::Role[1]).to eq('admin')
    end

    it '#[] with string or symbol' do
      expect(User::Role[:user]).to eq('user')
      expect(User::Role['admin']).to eq('admin')
    end

    it '#to_h' do
      expect(User::Role.to_h).to eq({
        user: 'user',
        admin: 'admin',
      })
    end

    it '#map' do
      expect(User::Role.map { |value| "value-#{value}" }).to eq(%w(value-user value-admin))
    end

    it '#empty?' do
      expect(User::Role.empty?).to eq(false)
    end

    it '#first' do
      expect(User::Role.first).to eq('user')
    end

    it '#last' do
      expect(User::Role.last).to eq('admin')
    end
  end

  describe 'i18n' do
    it 'translate with default scope' do
      I18n.expects(:t).with(:user, scope: 'users.role.base')
      User::Role.t(:user)
    end

    it 'translate with custom scope' do
      I18n.expects(:t).with(:user, scope: 'users.role.custom')
      User::Role.t(:user, :custom)
    end

    it 'is aliased with translate method' do
      I18n.expects(:t).with(:user, scope: 'users.role.base')
      User::Role.translate(:user)
    end
  end

  describe 'ActiveRecord Enum' do
    it 'does not set ActiveRecord Enum by default' do
      expect(User.defined_enums).to eq({})
    end

    it 'sets ActiveRecord Enum with no option' do
      expect(DummyDb.defined_enums).to eq('role' => {
        'user' => 'user',
        'admin' => 'admin',
      })

      methods = DummyDb.methods(false)
      expect(methods).to include(:roles)
      expect(methods).to include(:user)
      expect(methods).to include(:not_user)
      expect(methods).to include(:admin)
      expect(methods).to include(:not_admin)
    end

    it 'sets ActiveRecord Enum with prefix' do
      expect(DummyPrefix.defined_enums).to eq('role' => {
        'user' => 'user',
        'admin' => 'admin',
      })

      methods = DummyPrefix.methods(false)
      expect(methods).to include(:roles)
      expect(methods).to include(:role_user)
      expect(methods).to include(:not_role_user)
      expect(methods).to include(:role_admin)
      expect(methods).to include(:not_role_admin)
    end


    it 'sets ActiveRecord Enum with custom prefix' do
      expect(DummyCustomPrefix.defined_enums).to eq('role' => {
        'user' => 'user',
        'admin' => 'admin',
      })

      methods = DummyCustomPrefix.methods(false)
      expect(methods).to include(:roles)
      expect(methods).to include(:foobar_user)
      expect(methods).to include(:not_foobar_user)
      expect(methods).to include(:foobar_admin)
      expect(methods).to include(:not_foobar_admin)
    end
  end
end
