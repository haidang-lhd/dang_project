# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }

    trait :stocks do
      name { 'Stocks' }
    end

    trait :gold do
      name { 'Gold' }
    end

    trait :bonds do
      name { 'Bonds' }
    end

    trait :real_estate do
      name { 'Real Estate' }
    end

    trait :cryptocurrency do
      name { 'Cryptocurrency' }
    end

    trait :investment_fund_certificates do
      name { 'Investment Fund Certificates' }
    end
  end
end
