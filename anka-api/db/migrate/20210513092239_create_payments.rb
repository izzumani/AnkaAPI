class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.float :amount
      t.string :pspReference
      t.text :response_details
      t.text :md
      t.text :paResponse
      t.text :threeDS2Token
      t.boolean :accepted, default: false

      t.timestamps
    end
  end
end
