class RemoveWordHighlight < ActiveRecord::Migration
  def up
    remove_column :words, :highlight
  end

  def down
    add_column :words, :highlight, :string
    Word.find_each do |word| word.update_attribute(:highlight, word.name) end
  end
end
