class DeviseCreateUsers < ActiveRecord::Migration

  def self.up
    create_table(:users) do |t|
      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Token authenticatable
      t.string :authentication_token

      t.timestamps
    end
    add_index :users, :authentication_token, :unique => true
  end

  def self.down
    drop_table :users
  end

end
