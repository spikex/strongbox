require 'strongbox'

module Strongbox
  class Railtie < Rails::Railtie
    initializer 'strongbox.extend_active_record' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Strongbox
      end
    end
  end
end
