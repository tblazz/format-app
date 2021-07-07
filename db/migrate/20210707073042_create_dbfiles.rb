class CreateDbfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :dbfiles do |t|

      t.timestamps
    end
  end
end
