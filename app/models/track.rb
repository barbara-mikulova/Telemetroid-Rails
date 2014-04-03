class Track < ActiveRecord::Base

  belongs_to :feed
  has_many :shared_datas
end
