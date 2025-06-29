# == Schema Information
#
# Table name: categories
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'associations' do
    it { should have_many(:assets) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'creates a valid category' do
      category = build(:category)
      expect(category).to be_valid
    end

    it 'creates categories with different names' do
      category1 = create(:category)
      category2 = create(:category)
      expect(category1.name).not_to eq(category2.name)
    end
  end

  describe 'traits' do
    it 'creates stocks category' do
      category = create(:category, :stocks)
      expect(category.name).to eq('Stocks')
    end

    it 'creates gold category' do
      category = create(:category, :gold)
      expect(category.name).to eq('Gold')
    end

    it 'creates investment fund certificates category' do
      category = create(:category, :investment_fund_certificates)
      expect(category.name).to eq('Investment Fund Certificates')
    end
  end

  describe 'database constraints' do
    it 'requires name to be present' do
      category = build(:category, name: nil)
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end
  end
end
