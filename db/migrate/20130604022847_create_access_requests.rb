class CreateAccessRequests < ActiveRecord::Migration

  def change

    create_table :access_requests do |t|
      t.references :requester
      t.references :requestee
      t.string     :status, default: 'pending'
      t.timestamps
    end

    add_index :access_requests, :requester_id
    add_index :access_requests, :requestee_id

  end

end
