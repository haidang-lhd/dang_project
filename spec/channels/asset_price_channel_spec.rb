# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssetPriceChannel, type: :channel do
  let(:user) { create(:user) }

  before do
    stub_connection current_user: user
  end

  describe '#subscribed' do
    it 'subscribes to asset price updates stream' do
      subscribe
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from('asset_price_updates')
    end
  end

  describe '#unsubscribed' do
    it 'unsubscribes successfully' do
      subscribe
      expect { unsubscribe }.not_to raise_error
    end
  end
end
