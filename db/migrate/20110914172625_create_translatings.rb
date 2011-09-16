class CreateTranslatings < ActiveRecord::Migration
  def change
    create_table :translatings do |t|
      t.references :original, polymorphic: true
      t.references :translated, polymorphic: true

      t.timestamps
    end
  end
end
