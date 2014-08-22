#class Hotoffer
#  include ActiveModel::Validations
#  include ActiveModel::Conversion
#  extend ActiveModel::Naming
#
#  attr_accessor :id;
#  attr_accessor :title;
#  attr_accessor :currency;
#  attr_accessor :username;
#  attr_accessor :userpic;
#  attr_accessor :pic;
#
#  def initialize(attributes = {})
#    attributes.each do |name, value|
#      send("#{name}=", value)
#    end
#  end
#
#  def persisted?
#    false
#  end
#
#end