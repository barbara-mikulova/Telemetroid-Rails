class User < ActiveRecord::Base
  
  has_many :devices
  
  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, length: {minimum: 6}
  validates :mail, presence: true, :email => true  
end
