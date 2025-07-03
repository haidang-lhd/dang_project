# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { build(:user, email: 'test@example.com') } # Use build instead of create to avoid confirmation issues

  describe '#confirmation_instructions' do
    let(:token) { 'sample_confirmation_token' }
    let(:mail) { UserMailer.confirmation_instructions(user, token) }

    it 'sends email to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Please confirm your account')
    end

    it 'has the correct sender' do
      expect(mail.from).to eq(['noreply@yourdomain.com'])
    end

    it 'includes confirmation token in body' do
      expect(mail.body.encoded).to include("Your confirmation token is: #{token}")
      expect(mail.body.encoded).to include(token)
    end

    it 'includes user email in body' do
      expect(mail.body.encoded).to include(user.email)
    end

    it 'includes welcome message' do
      expect(mail.body.encoded).to include('Welcome')
    end
  end

  describe '#reset_password_instructions' do
    let(:token) { 'sample_reset_token' }
    let(:mail) { UserMailer.reset_password_instructions(user, token) }

    it 'sends email to the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Reset your password')
    end

    it 'has the correct sender' do
      expect(mail.from).to eq(['noreply@yourdomain.com'])
    end

    it 'includes reset token in body' do
      expect(mail.body.encoded).to include('Reset Token: sample_reset_token')
    end

    it 'includes user email in body' do
      expect(mail.body.encoded).to include(user.email)
    end

    it 'includes reset instructions' do
      expect(mail.body.encoded).to include('Please use the following token to reset your password')
    end
  end
end
