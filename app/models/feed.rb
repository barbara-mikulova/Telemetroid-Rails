class Feed < ActiveRecord::Base
  has_many :admins
  has_many :writers
  has_many :readers
  has_many :writing_devices
  has_many :reading_devices
  
  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
  
  before_validation :generate_identifier
  
  def generate_identifier
    if self.identifier
      return
    end
    identifier = SecureRandom.urlsafe_base64(20)
    while Feed.find_by_identifier(identifier) != nil
      identifier = SecureRandom.base64(20)
    end
    self.identifier = identifier
  end
  
end
