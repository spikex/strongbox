module Strongbox
  VERSION = "0.0.0"

  class << self
    
  end

  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
  
  if Object.const_defined?("ActiveRecord")
    ActiveRecord::Base.send(:include, Strongbox)
  end
end
