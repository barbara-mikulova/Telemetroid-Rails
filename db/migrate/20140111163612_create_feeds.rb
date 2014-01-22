class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :comment
      t.boolean :private, default: true
      t.string :identifier

      t.timestamps
    end
  end
end
