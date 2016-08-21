class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|
      t.references :tour

      t.string		:title, :default => ""
      t.text		:description

      t.timestamps
    end
  end
end
