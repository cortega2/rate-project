class AddTimezoneToRate < ActiveRecord::Migration[5.2]
  def change
    add_column :rates, :timezone, :string
  end
end
