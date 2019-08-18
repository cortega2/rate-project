class ChangeTimesToBeDatetimesInRates < ActiveRecord::Migration[5.2]
  def change
    change_column :rates, :start, :datetime
    change_column :rates, :end, :datetime
  end
end
