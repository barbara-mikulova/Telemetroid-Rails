class Feed < ActiveRecord::Base
  has_many :admins
  has_many :writers
  has_many :readers
  has_many :writing_devices
  has_and_belongs_to_many :shared_datas
  has_and_belongs_to_many :tracks

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true

  before_validation :generate_keys, :generate_identifier

  private
  def generate_identifier
    if self.identifier
      return
    end
    identifier = SecureRandom.hex(20)
    while Feed.find_by_identifier(identifier) != nil
      identifier = SecureRandom.hex(20)
    end
    self.identifier = identifier
  end

  def generate_keys
    generate_read_key
    generate_write_key
  end

  def generate_write_key
    if !self.write_key
      key = SecureRandom.hex(20)
      while Feed.find_by_write_key(key) != nil
        key = SecureRandom.hex(20)
      end
      self.write_key = key
    end
  end

  def generate_read_key
    if !self.read_key
      key = SecureRandom.hex(20)
      while Feed.find_by_read_key(key) != nil
        key = SecureRandom.hex(20)
      end
      self.read_key = key
    end
  end

end
