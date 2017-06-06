module CategoryModule
  module ClassMethods
    def self.extended(base) # fires at start-up (during Class-level instantiation)
      base.class_variable_set(:@@all, HashWithBsearch.new) # {|a,b| a<=>b})
    end

    def all
      return self.class_variable_get(:@@all)
    end

    def create_or_get_existing(id_string)
      retrieved_object = self.all[id_string]
      if retrieved_object == nil
        retrieved_object = self.new(id_string)
      end
      return retrieved_object
    end
  end

  module InstanceMethods
  end
end
