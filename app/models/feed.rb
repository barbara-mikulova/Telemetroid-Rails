class Feed < ActiveRecord::Base
  has_many :admins
  has_many :writers
  has_many :readers
  has_many :writing_devices
  has_many :reading_devices
  
  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
  
  before_validation :generate_identifier
  before_create :generate_keys
  
  def generate_identifier
    if self.identifier
      return
    end
    identifier = SecureRandom.urlsafe_base64(20)
    while Feed.find_by_identifier(identifier) != nil
      identifier = SecureRandom.urlsafe_base64(20)
    end
    self.identifier = identifier
  end

  private
  def generate_keys
    if self.read_key
      return
    end
    read_key = SecureRandom.urlsafe_base64(20)
    while Feed.find_by_read_key(read_key) != nil
      read_key = SecureRandom.urlsafe_base64(20)
    end
    self.read_key = read_key
  end

end
