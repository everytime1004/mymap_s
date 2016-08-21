class CreateTours < ActiveRecord::Migration[5.0]
  def change
    create_table :tours do |t|
      t.references	:user
      t.string		:title, :default => ""
      t.string		:description, :default => ""
      t.string		:location, :default => ""
      t.string		:theme, :default => ""
      t.string		:distance, :default => ""

      t.timestamps
    end
  end
end
