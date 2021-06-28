class CreatePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :plans do |t|
      t.string :title
      t.string :description
      t.float :fees

      t.timestamps
    end
  end
end
