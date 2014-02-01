class SharedInfo < ActiveRecord::Base
  belongs_to :feed
  belongs_to :device
end
