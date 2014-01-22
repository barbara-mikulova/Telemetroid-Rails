class CreateReadingDevices < ActiveRecord::Migration
  def change
    create_table :reading_devices do |t|
      t.references :device, index: true
      t.references :feed, index: true

      t.timestamps
    end
  end
end
