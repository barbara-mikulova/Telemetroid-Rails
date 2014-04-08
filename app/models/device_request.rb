class DeviceRequest < ActiveRecord::Base

  belongs_to :device

  self.primary_key = 'identifier'

end
