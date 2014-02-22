class SharedData < ActiveRecord::Base

  belongs_to :device
  has_and_belongs_to_many :feeds
end
