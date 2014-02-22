class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :identifier
      t.string :name
      t.string :password
      t.string :comment
      t.integer :current_track, default: 1
      t.boolean :public, default: false
      t.references :user, index: true

      t.timestamps
    end
  end
end
