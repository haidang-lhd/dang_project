# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           not null
#  encrypted_password     :string
#  password_digest        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }

    # Skip confirmation callback in test environment
    after(:build) do |user|
      user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    end

    # Trait for confirmed users
    trait :confirmed do
      after(:create) do |user|
        user.confirm if user.respond_to?(:confirm)
      end
    end

    # Trait for unconfirmed users (explicit)
    trait :unconfirmed do
      after(:build) do |user|
        # Allow confirmation process to run normally
      end

      after(:create) do |user|
        user.update_columns(confirmed_at: nil) if user.confirmed?
      end
    end

    # Trait for users with confirmation token
    trait :with_confirmation_token do
      after(:create) do |user|
        user.send_confirmation_instructions if user.respond_to?(:send_confirmation_instructions)
      end
    end

    # Trait for users with reset password token
    trait :with_reset_password_token do
      after(:create) do |user|
        user.send_reset_password_instructions if user.respond_to?(:send_reset_password_instructions)
      end
    end

    trait :with_transactions do
      after(:create) do |user|
        create_list(:investment_transaction, 3, user: user)
      end
    end
  end
end
