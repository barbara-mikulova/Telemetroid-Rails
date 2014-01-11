class CreateReaders < ActiveRecord::Migration
  def change
    create_table :readers do |t|
      t.references :user, index: true
      t.references :feed, index: true

      t.timestamps
    end
  end
end
