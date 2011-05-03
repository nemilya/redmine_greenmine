module RedmineGreenmine
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          belongs_to :gm_responsible, :class_name => 'User', :foreign_key => 'gm_responsible_id'

#          delegate :title, :to => :deliverable, :prefix => true, :allow_nil => true
#          delegate :contract, :to => :deliverable, :allow_nil => true

        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end
