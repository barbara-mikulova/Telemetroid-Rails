class CreateWriters < ActiveRecord::Migration
  def change
    create_table :writers do |t|
      t.references :user, index: true
      t.references :feed, index: true

      t.timestamps
    end
  end
end
