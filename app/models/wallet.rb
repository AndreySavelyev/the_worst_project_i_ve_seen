class Wallet < ActiveRecord::Base
  belongs_to :Profile
  belongs_to :IsoCurrency
  has_many :Request, name:"source"
  has_many :Request, name:"target"
end
