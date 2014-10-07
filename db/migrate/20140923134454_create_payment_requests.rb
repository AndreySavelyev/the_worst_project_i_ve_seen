class CreatePaymentRequests < ActiveRecord::Migration
  def up
    #конечная сумма назначения
    change_column :feeds, :amount, :float

    add_column :feeds, :source_currency, :integer
    add_column :feeds, :source_amount, :float

    #conversation rate ID
    add_column :feeds, :rate_id, :integer
    #conversation commission amount
    add_column :feeds, :conv_commission_amount, :float
    #conversation commission ID
    add_column :feeds, :conv_commission_id, :integer

    #transaction commission id
    add_column :feeds, :trans_commission_id, :integer
    #transaction commission currency
    add_column :feeds, :trans_commission_currency, :integer
    #transaction commission amount
    add_column :feeds, :trans_commission_amount, :float


    add_column :profiles, :available, :float, default: 0
    add_column :profiles, :holded, :float, default: 0
    add_column :profiles, :iso_currency, :string, index: true , default: 'EUR'
    add_column :profiles, :lock_version, :integer, default: 0

    add_column :iso_currencies, :IsoName, :string
  end

  def down
    #
    change_column :feeds, :amount, :integer
    #
    remove_column :feeds, :source_amount
    #
    remove_column :feeds, :source_currency

    #conversation rate ID
    remove_column :feeds, :rate_id
    #conversation commission amount
    remove_column :feeds, :conv_commission_amount
    #conversation commission ID
    remove_column :feeds, :conv_commission_id

    #transaction commission id
    remove_column :feeds, :trans_commission_id
    #transaction commission currency
    remove_column :feeds, :trans_commission_currency
    #transaction commission amount
    remove_column :feeds, :trans_commission_amount

    remove_column  :profiles, :available
    remove_column  :profiles, :holded
    remove_column  :profiles, :iso_currency
    remove_column  :profiles, :lock_version

    remove_column :iso_currencies, :IsoName
  end
end
