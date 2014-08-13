class Request < ActiveRecord::Base
  has_one :wallet, name:"source"
  has_one :wallet, name:"target"
end
