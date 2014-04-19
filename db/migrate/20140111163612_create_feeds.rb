class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :comment
      t.string :identifier
      t.string :read_key
      t.string :write_key

      t.timestamps
    end
  end
end
