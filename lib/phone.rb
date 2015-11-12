class Phone < ActiveRecord::Base
  belongs_to :contact

  validates :label, presence: true
  validates :digits, length: { minimum: 7 }, numericality: { only_integer: true }
end