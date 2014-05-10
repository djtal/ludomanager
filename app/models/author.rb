# encoding: UTF-8

class Author < ActiveRecord::Base
  validates :name, presence: true
  validates :lang, inclusion: { in: ::Ludomanager::ISOCODES, allow_nil: true, allow_blank: true }

  has_many :authorships, dependent: :destroy
  has_many :games, through: :authorships

  def self.find_or_create_from_str str = nil
    return nil if !str
    name, surname = parse_str(str)
    return nil if name.blank? || surname.blank?
    a = find_by_name_and_surname(name, surname) || find_by_surname_and_name(name, surname)
    if !a
      a = Author.new(name: name, surname: surname)
      a.save
    end
    a
  end

  def self.parse_str str =  nil
    return "","" if str.blank?
    if str.strip =~ /(.*)\s*-\s*(.*)/i
      return $2.strip, $1.strip
    else
      s = str.split
      if(s.size < 2)
        return "", s[0]
      elsif s == 2
        return s[1], s[0]
      else
        return s[s.size - 1], s[0..(s.size - 2)] * " "
      end
    end
  end

  def display_name
    self.new_record? ? "" : (surname.blank? ? name : "#{surname} - #{name}")
  end

  def display_name=(str)
    self.name, self.surname = self.class.parse_str(str)
  end

end
