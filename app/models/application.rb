class Application < ActiveRecord::Base
  has_many :providers, dependent: :destroy
  has_many :sessions
end
