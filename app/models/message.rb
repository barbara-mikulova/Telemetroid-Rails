class Message < ActiveRecord::Base
  belongs_to :device
  belongs_to :user

  validates :message, presence: true
  validates :user_id, presence: true
  validates :device_id, presence: true
end
