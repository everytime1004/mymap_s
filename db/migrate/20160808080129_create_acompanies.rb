class CreateAcompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :acompanies do |t|
      t.references	:tour
      
      t.integer 	:user_id

      t.timestamps
    end
  end
end
