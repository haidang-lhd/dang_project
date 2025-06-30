# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string           not null
#  encrypted_password :string
#  password_digest    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:investment_transactions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:password) }
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'creates users with unique emails' do
      user1 = create(:user)
      user2 = create(:user)
      expect(user1.email).not_to eq(user2.email)
    end
  end

  describe 'password authentication' do
    let(:user) { create(:user, password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end

  describe 'traits' do
    it 'creates user with transactions' do
      user = create(:user, :with_transactions)
      expect(user.investment_transactions.count).to eq(3)
    end
  end

  describe 'secure password' do
    it 'encrypts password' do
      user = create(:user, password: 'password123')
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq('password123')
    end
  end
end
