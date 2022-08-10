# frozen_string_literal: true

RSpec.describe ND::Enum::Base do
  let(:model) {
    Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
      nd_enum(role: %w(user admin))
    end
  }

  it '#all' do
    expect(model::Role.all).to eq(%w(user admin))
  end

  it '#size' do
    expect(model::Role.size).to eq(2)
  end

  it '#length' do
    expect(model::Role.length).to eq(2)
  end

  it '#[] with integer' do
    expect(model::Role[0]).to eq('user')
    expect(model::Role[1]).to eq('admin')
  end

  it '#[] with string or symbol' do
    expect(model::Role[:user]).to eq('user')
    expect(model::Role['admin']).to eq('admin')
  end

  it '#to_h' do
    expect(model::Role.to_h).to eq({
      user: 'user',
      admin: 'admin',
    })
  end

  it '#map' do
    expect(model::Role.map { |value| "value-#{value}" }).to eq(%w(value-user value-admin))
  end

  it '#empty?' do
    expect(model::Role.empty?).to eq(false)
  end

  it '#first' do
    expect(model::Role.first).to eq('user')
  end

  it '#last' do
    expect(model::Role.last).to eq('admin')
  end
end
