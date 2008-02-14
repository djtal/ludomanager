if RAILS_ENV == 'test'
  Object.class_eval do
    def self.superclasses
      return Set.new if superclass.nil?
      superclass.superclasses.dup << superclass
    end

    def context(name, superclass = nil, &block)
      # create class first so it has a name before evaling the block.  this is so fixtures work correctly.
      klass ||= self.is_a?(Class) && superclasses.include?(Test::Unit::TestCase) ? self : Test::Unit::TestCase
      returning self.class.const_set(self.class.convert_bdd_name(name).camelize + 'Test', Class.new(klass)) do |klass|
        klass.class_eval &block
      end
    end
    
    def self.convert_bdd_name(name)
      name.to_s.gsub(/[^\w ]+/, '').gsub(/ +/, '_')
    end
  end

  class << Test::Unit::TestCase
    def specify(name, &block)
      define_method 'test_' + convert_bdd_name(name), &block
    end
  end
end