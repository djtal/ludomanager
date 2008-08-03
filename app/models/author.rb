# == Schema Information
# Schema version: 20080731203551
#
# Table name: authors
#
#  id       :integer       not null, primary key
#  name     :string(255)   
#  surname  :string(255)   
#  homepage :string(255)   
#


class Author < ActiveRecord::Base
  validates_presence_of :name, :on => :create, :message => "can't be blank"
  has_many :authorships
  has_many :games, :through => :authorships
  
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
    return "","" if str.nil? || str.blank?
    str.strip!
    if str =~ /(\w*)\s*-\s*(\w*)/i
      return $2, $1
    else
      s = str.split
      return s[1], s[0] 
    end
  end
  
  def display_name
    self.new_record? ? "" : (surname.blank? ? name : "#{surname} - #{name}")
  end
  
  def display_name=(str)
    self.name, self.surname = self.class.parse_str(str)
  end
  
end
