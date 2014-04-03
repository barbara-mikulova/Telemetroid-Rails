class CreateSharedData < ActiveRecord::Migration
  def change
    create_table :shared_data do |t|
      t.string :time_stamp
      t.text :json_data
      t.integer :track_id
      t.references :device, index: true
      t.references :track, index: true

      t.timestamps
    end
  end
end
