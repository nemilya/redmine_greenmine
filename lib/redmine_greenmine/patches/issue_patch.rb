module RedmineGreenmine
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          belongs_to :gm_responsible, :class_name => 'User', :foreign_key => 'gm_responsible_id'

          # redmine 1.3, compatible for 1.2
          validate :validate_issue


          alias_method_chain :default_assign, :assign_matrix
          alias_method_chain :recipients,     :gm_responsible
          alias_method_chain :validate_issue, :issue_category_fill # проверка на наличие кастомного поля у проекта, и если выставлено - проверять заполненность поля категории
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def default_assign_with_assign_matrix
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


        # если выставлено кастомное поле у проекта "IssueCategoryFill"
        # и оно "тру" - то проверять наличие заполненного поля "category_id"
        # based on 1.3 version
        def validate_issue_with_issue_category_fill 
          # new
          if project
            project.custom_field_values.each do |value|
              if value.custom_field.name == 'IssueCategoryFill'
                if value.true? && category_id.nil?
                  errors.add :category_id, ' - не заполнена, необходимо заполнить'
                  break
                end
              end
            end
          end
          # /new

          if self.due_date.nil? && @attributes['due_date'] && !@attributes['due_date'].empty?
            errors.add :due_date, :not_a_date
          end

          if self.due_date and self.start_date and self.due_date < self.start_date
            errors.add :due_date, :greater_than_start_date
          end

          if start_date && soonest_start && start_date < soonest_start
            errors.add :start_date, :invalid
          end

          if fixed_version
            if !assignable_versions.include?(fixed_version)
              errors.add :fixed_version_id, :inclusion
            elsif reopened? && fixed_version.closed?
              errors.add :base, I18n.t(:error_can_not_reopen_issue_on_closed_version)
            end
          end

          # Checks that the issue can not be added/moved to a disabled tracker
          if project && (tracker_id_changed? || project_id_changed?)
            unless project.trackers.include?(tracker)
              errors.add :tracker_id, :inclusion
            end
          end

          # Checks parent issue assignment
          if @parent_issue
            if @parent_issue.project_id != project_id
              errors.add :parent_issue_id, :not_same_project
            elsif !new_record?
              # moving an existing issue
              if @parent_issue.root_id != root_id
                # we can always move to another tree
              elsif move_possible?(@parent_issue)
                # move accepted inside tree
              else
                errors.add :parent_issue_id, :not_a_valid_parent
              end
            end
          end
        end
      
      
      end

    end
  end
end
