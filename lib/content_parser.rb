module TeamScore
  class Filter
    ALLOWED_RESOURCES = [:game]
    
    # convert <game:4 title> into textile link to game re
    # use game title as link name
    # "Google":http://google.com.
    #
    def self.filter(str)
      if str
        str.gsub(/<([a-z]+):(\d+)>/) do |match|
          create_link_for($1,$2, match)
        end
      end
    end
    
    def self.create_link_for(resource_type, id, match)
      raise "Macro #{match} not allowed" unless ALLOWED_RESOURCES.include?(resource_type.to_sym)
      object = resource_type.classify.constantize.find(id)
      "\"#{object.name}\":http://www.teamscore.org/#{object.class.name.pluralize.downcase}/#{object.id}"
    end
  end
end
