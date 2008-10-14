class CreateEditor < ActiveRecord::Migration
  def self.up
    Game.all.each do |g|
      unless g.editor.blank?
        e = Editor.find_or_create_by_name(g.editor.strip.humanize)
        ed = g.editions.build
        ed.editor = e
        ed.name = g.vo_name unless g.vo_name.blank?
        ed.published_at = g.published_at
        ed.save
      end
    end
  end

  def self.down
  end
end
