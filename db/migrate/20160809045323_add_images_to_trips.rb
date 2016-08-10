class AddImagesToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :images, :json
  end
end
