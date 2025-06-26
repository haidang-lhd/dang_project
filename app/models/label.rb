# == Schema Information
#
# Table name: labels
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_labels_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Label < ApplicationRecord
  belongs_to :user
  has_many :asset_labels
  has_many :assets, through: :asset_labels

  validates :name, presence: true
end
