class AddImagesToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :images, :string, array: true, default: []
  end
end
