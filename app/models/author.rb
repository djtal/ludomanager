# == Schema Information
# Schema version: 20090324224831
#
# Table name: authors
#
#  id       :integer       not null, primary key
#  name     :string(255)   
#  surname  :string(255)   
#  homepage :string(255)   
#

class Author < ActiveRecord::Base
  validates_presence_of :name
  has_many :authorships, :dependent => :destroy
  has_many :games, :through => :authorships
  validates_inclusion_of :lang, :in => ::Ludomanager::ISOCODES, :allow_nil => true, :allow_blank => true
  
  
  scope_procedure :start, searchlogic_lambda(:string){|letter| name_begins_with_any(letter.downcase, letter.upcase).ascend_by_surname}
  
  def self.find_or_create_from_str str = nil
    return nil if !str
    name, surname = parse_str(str)
    return nil if name.blank? || surname.blank?
    a = find_by_name_and_surname(name, surname) || find_by_surname_and_name(name, surname)
    if !a
      a = Author.new(:name => name, :surname => surname)
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
