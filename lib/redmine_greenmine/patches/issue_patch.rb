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
          alias_method_chain :recipients,     :gm_responsible
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


        # Returns the mail adresses of users that should be notified
        # Based on Redmine 1.3 version
        def recipients_with_gm_responsible
          notified = project.notified_users
          # Author and assignee are always notified unless they have been
          # locked or don't want to be notified
          notified << author if author && author.active? && author.notify_about?(self)
          if assigned_to
            if assigned_to.is_a?(Group)
              notified += assigned_to.users.select {|u| u.active? && u.notify_about?(self)}
            else
              notified << assigned_to if assigned_to.active? && assigned_to.notify_about?(self)
            end
          end

          # new
          notified << gm_responsible if gm_responsible && gm_responsible.active? # && gm_responsible.notify_about?(self)
          # /new

          notified.uniq!
          # Remove users that can not view the issue
          notified.reject! {|user| !visible?(user)}
          notified.collect(&:mail)
        end

      end

    end
  end
end
