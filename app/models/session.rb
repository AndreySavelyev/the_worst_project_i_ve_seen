class Session < ActiveRecord::Base
  belongs_to :profile
  belongs_to :application
end
