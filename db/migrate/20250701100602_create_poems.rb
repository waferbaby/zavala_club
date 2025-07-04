class CreatePoems < ActiveRecord::Migration[8.0]
  def change
    create_table :poems do |t|
      t.integer :form
      t.text :contents

      t.timestamps
    end
  end
end
