class Tabs
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :shopping;
    attr_accessor :services;
    attr_accessor :social;

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def persisted?
      false
    end
  end