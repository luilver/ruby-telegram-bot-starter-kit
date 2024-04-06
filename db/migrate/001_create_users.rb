class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, force: true do |t|
      t.integer :uid
    end
  end
end
