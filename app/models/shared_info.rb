class SharedInfo < ActiveRecord::Base
  belongs_to :feed
  belongs_to :device

  validates :feed_id, presence: true
  validates :device_id, presence: true
  validates :json, presence: true

end
