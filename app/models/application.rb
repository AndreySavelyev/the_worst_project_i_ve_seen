class Application < ActiveRecord::Base
  has_many :providers, dependent: :destroy
end
