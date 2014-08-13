class Wallet < ActiveRecord::Base
  belongs_to :Profile
  belongs_to :IsoCurrency
  belongs_to :session
  has_many :requests
end
