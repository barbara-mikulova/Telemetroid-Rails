class Track < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :feeds
  has_many :shared_datas

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true

  before_validation :generate_identifier

  private
  def generate_identifier
    if self.identifier
      return
    end
    identifier = SecureRandom.hex(20)
    while Track.find_by_identifier(identifier) != nil
      identifier = SecureRandom.hex(20)
    end
    self.identifier = identifier
  end
end
