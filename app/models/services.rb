class Services
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attr_accessor :promolink;
    attr_accessor :provider;
    attr_accessor :hotoffer;
    attr_accessor :feeditem;

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def persisted?
      false
    end
  end