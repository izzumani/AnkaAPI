class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.references :payment, null: false, foreign_key: true
      t.boolean :active

      t.timestamps
    end
  end
end
