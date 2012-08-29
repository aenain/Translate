class AddNameLangIndexToWords < ActiveRecord::Migration
  def change
    add_index :words, :name
    add_index :words, [:name, :lang], unique: true
  end
end
