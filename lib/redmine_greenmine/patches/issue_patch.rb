module RedmineGreenmine
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          belongs_to :gm_responsible, :class_name => 'User', :foreign_key => 'gm_responsible_id'

          alias_method_chain :default_assign, :assign_matrix
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def default_assign_with_assign_matrix
          # TODO
          if assigned_to.nil? # && category && category.assigned_to
            self.assigned_to = DefaultAssignItem.get_assigned_for_issue(self)
          end
          #if assigned_to.nil? && category && category.assigned_to
          #  self.assigned_to = category.assigned_to
          #end
        end
      end

    end
  end
end
