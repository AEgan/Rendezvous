class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.float :latitude
      t.float :longitude
      t.time :start_time
      t.time :end_time
      t.boolean :active
      t.integer :user_id

      t.timestamps
    end
  end
end
