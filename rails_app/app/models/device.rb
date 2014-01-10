class Device < ActiveRecord::Base
  
  belongs_to :user
  
  validates :identifier, presence: true, uniqueness: true
  validates :password, presence: true
  validates :name, presence: true, uniqueness: { scope: :user, message: "must be unique" }

end
