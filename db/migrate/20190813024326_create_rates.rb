class CreateRates < ActiveRecord::Migration[5.2]
  def change
    create_table :rates do |t|
      t.text :day_key
      t.float :price
      t.time :start
      t.time :end

      t.timestamps
    end
  end
end
