class Venue < ApplicationRecord
  has_many :events, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true
  validates :address, presence: true
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
