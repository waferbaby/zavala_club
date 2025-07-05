class AddHashToPoems < ActiveRecord::Migration[8.0]
  def change
    add_column :poems, :digest, :string
    add_index :poems, :digest, unique: true
  end
end
