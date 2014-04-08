class Device < ActiveRecord::Base
  
  belongs_to :user
  has_many :device_requests
  
  validates :identifier, presence: true, uniqueness: true
  validates :password, presence: true
  validates :name, presence: true, uniqueness: { scope: :user, message: "must be unique" }
  
  before_validation :generate_name_and_password
  
  def generate_name_and_password
    if !self.name
      new_name = SecureRandom.hex(10)
      while Device.find_by_name(new_name) != nil
        new_name = SecureRandom.hex(10)
      end
      self.name = new_name
    end
    if !self.password
      self.password = SecureRandom.hex(10)
    end
  end

end
