class CreateDeviceRequests < ActiveRecord::Migration
  def change
    create_table :device_requests do |t|
      t.string :identifier
      t.references :device, index: true
      t.timestamps
    end
  end
end
