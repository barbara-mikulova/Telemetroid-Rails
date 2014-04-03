class FeedsTracks < ActiveRecord::Migration
  def change
    create_table :feeds_tracks do |t|
      t.references :track, index: true
      t.references :feed, index: true
    end
  end
end
