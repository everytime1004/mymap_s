class CreateTours < ActiveRecord::Migration[5.0]
  def change
    create_table :tours do |t|
      t.references	:user
      t.string		:title
      t.string		:description
      t.string		:location
      t.string		:theme
      t.string		:expense
      t.string		:distance

      t.timestamps
    end
  end
end
