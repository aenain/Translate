class CreateContexts < ActiveRecord::Migration
  def change
    create_table :contexts do |t|
      t.string :sentence, limit: 150

      t.timestamps
    end
  end
end
