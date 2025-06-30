# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'noreply@yourdomain.com'

  def confirmation_instructions(record, token, opts = {})
    @token = token
    @resource = record
    @confirmation_url = "#{Rails.application.config.action_mailer.default_url_options[:host]}:#{Rails.application.config.action_mailer.default_url_options[:port]}/users/confirmation?confirmation_token=#{@token}"

    mail(
      to: @resource.email,
      subject: 'Please confirm your account'
    )
  end

  def reset_password_instructions(record, token, opts = {})
    @token = token
    @resource = record
    # Không tạo reset_url nữa, chỉ gửi token

    mail(
      to: @resource.email,
      subject: 'Reset your password - Token'
    )
  end
end
