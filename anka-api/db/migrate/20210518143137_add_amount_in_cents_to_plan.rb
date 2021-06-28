class AddAmountInCentsToPlan < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :amount_in_cents, :integer
  end
end
