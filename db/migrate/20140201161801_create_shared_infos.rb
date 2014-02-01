class CreateSharedInfos < ActiveRecord::Migration
  def change
    create_table :shared_infos do |t|
      t.string :json
      t.references :feed, index: true
      t.references :device, index: true

      t.timestamps
    end
  end
end
