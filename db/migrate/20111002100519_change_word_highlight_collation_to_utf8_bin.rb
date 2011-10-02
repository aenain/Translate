class ChangeWordHighlightCollationToUtf8Bin < ActiveRecord::Migration
  def up
    # polskie znaki wymagają takiej modyfikacji w przeciwnym razie:
    # select words.* from words where words.highlight like '%ea%'; zwróci np. 'jeść'
    execute %Q{alter table words modify `highlight` varchar(255) collate utf8_bin}
  end

  def down
    execute %Q{alter table words modify `highlight` varchar(255) collate utf8_unicode_ci}
  end
end
