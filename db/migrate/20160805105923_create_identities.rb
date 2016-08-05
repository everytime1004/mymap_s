class CreateIdentities < ActiveRecord::Migration[5.0]
  def change
    create_table :identities do |t|
      t.references :user, foreign_key: true
      t.string :provider
      t.string :accesstoken
      t.string :refreshtoken
      t.string :uid
      t.string :email
      t.string :photo

      t.timestamps
    end
  end
end
