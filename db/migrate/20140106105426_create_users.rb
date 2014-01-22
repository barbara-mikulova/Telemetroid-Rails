class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :mail
      t.string :name
      t.string :comment
      t.boolean :public_email, default: false

      t.timestamps
    end
  end
end
