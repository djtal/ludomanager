# encoding: UTF-8
module EditorsHelper
  def other_editor_for(edition, curent_editor)
    other = edition.game.editors.map(&:name)
    (other.uniq - [curent_editor.name]) * ","
  end
end
