class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user, index: true
      t.references :device, index: true
      t.string :message
      t.boolean :read_by_user, default: false
      t.boolean :read_by_device, default: false

      t.timestamps
    end
  end
end
