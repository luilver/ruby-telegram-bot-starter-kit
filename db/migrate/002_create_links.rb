# frozen_string_literal: true

class CreateLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :links, force: true do |t|
      t.integer :uid
      t.string :url, null: false
    end
  end
end
