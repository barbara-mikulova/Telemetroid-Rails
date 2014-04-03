class SharedDataTracks < ActiveRecord::Migration
  def change
    create_table :shared_data_tracks do |t|
      t.references :track, index: true
      t.references :shared_data, index: true
    end
  end
end
