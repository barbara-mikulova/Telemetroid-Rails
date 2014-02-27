class Message < ActiveRecord::Base
  serialize :message, Hash

  belongs_to :device
  belongs_to :user
end
