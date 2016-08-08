class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|
      t.references :tour

      t.timestamps
    end
  end
end
