class MigrateEditorsToPaperclip < ActiveRecord::Migration
  def self.up
    Editor.find(:all).each do |e|
      if e.logo_old
        e.logo = File.open(e.logo_old.full_filename)
        e.save
      end
    end
  end

  def self.down
  end
end
