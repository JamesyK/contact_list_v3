class Contact < ActiveRecord::Base
  has_many :phones

  validates :firstname, :lastname, :email, presence: true
  validates :email, uniqueness: true
end