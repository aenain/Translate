class AddHighlightToWord < ActiveRecord::Migration
  def change
    add_column :words, :highlight, :string, :default => ''
  end
end
