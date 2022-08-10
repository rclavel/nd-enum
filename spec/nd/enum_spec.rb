# frozen_string_literal: true

RSpec.describe ND::Enum do
  describe 'constants' do
    let(:model) {
      Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(role: %w(user admin))
      end
    }

    it 'defines a module for the enum' do
      expect(model.constants).to include(:Role)
      expect(model::Role.class).to be(Module)
    end

    it 'defines a constant for each enum value' do
      expect(model::Role.constants.sort).to eq(%i(ADMIN USER))
      expect(model::Role::USER).to eq('user')
      expect(model::Role::ADMIN).to eq('admin')
    end
  end

  describe 'ActiveRecord Enum' do
    it 'does not set ActiveRecord Enum by default' do
      model = Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(role: %w(user admin))
      end

      expect(model.defined_enums).to eq({})
    end

    it 'sets ActiveRecord Enum with no option' do
      model = Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(role: %w(user admin), db: true)
      end

      expect(model.defined_enums).to eq('role' => {
        'user' => 'user',
        'admin' => 'admin',
      })

      methods = model.methods(false)
      expect(methods).to include(:roles)
      expect(methods).to include(:user)
      expect(methods).to include(:not_user)
      expect(methods).to include(:admin)
      expect(methods).to include(:not_admin)
    end

    it 'sets ActiveRecord Enum with prefix' do
      model = Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(role: %w(user admin), db: { prefix: true })
      end

      expect(model.defined_enums).to eq('role' => {
        'user' => 'user',
        'admin' => 'admin',
      })

      methods = model.methods(false)
      expect(methods).to include(:roles)
      expect(methods).to include(:role_user)
      expect(methods).to include(:not_role_user)
      expect(methods).to include(:role_admin)
      expect(methods).to include(:not_role_admin)
    end

    it 'sets ActiveRecord Enum with custom prefix' do
      model = Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        nd_enum(role: %w(user admin), db: { prefix: 'foobar' })
      end

      expect(model.defined_enums).to eq('role' => {
        'user' => 'user',
        'admin' => 'admin',
      })

      methods = model.methods(false)
      expect(methods).to include(:roles)
      expect(methods).to include(:foobar_user)
      expect(methods).to include(:not_foobar_user)
      expect(methods).to include(:foobar_admin)
      expect(methods).to include(:not_foobar_admin)
    end
  end
end
