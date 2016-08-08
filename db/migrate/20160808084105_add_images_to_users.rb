class AddImagesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :images, :string, array: true, default: []
  end
end
