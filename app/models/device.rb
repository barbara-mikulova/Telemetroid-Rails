class Device < ActiveRecord::Base
  
  belongs_to :user
  
  validates :identifier, presence: true, uniqueness: true
  validates :password, presence: true
  validates :name, presence: true, uniqueness: { scope: :user, message: "must be unique" }
  
  before_validation :generate_name_and_password
  
  def generate_name_and_password
    if !self.name
      new_name = SecureRandom.base64(20)
      while Device.find_by_name(new_name) != nil
        new_name = SecureRandom.base64(20)
      end
      self.name = new_name
    end
    if !self.password
      self.password = SecureRandom.base64(20)
    end
  end

end
