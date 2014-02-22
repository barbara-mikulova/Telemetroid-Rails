class FeedsSharedData < ActiveRecord::Migration
  def change
    create_table :feeds_shared_data do |t|
      t.references :shared_data, index: true
      t.references :feed, index: true
    end
  end
end
