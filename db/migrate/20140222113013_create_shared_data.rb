class CreateSharedData < ActiveRecord::Migration
  def change
    create_table :shared_data do |t|
      t.string :time_stamp
      t.string :json_data
      t.references :device, index: true

      t.timestamps
    end

    create_table :shared_data_feeds do |t|
      t.belongs_to :shared_data
      t.belongs_to :feed
    end
  end
end
