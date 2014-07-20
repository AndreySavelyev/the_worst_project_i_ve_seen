class Feeditem
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :id;
  attr_accessor :date;
  attr_accessor :likes;
  attr_accessor :message;
  attr_accessor :userpic;
  attr_accessor :type;

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end