module RedmineGreenmine
  module Patches
    module QueryPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :available_filters, :gm_filters
        end
      end

      module InstanceMethods
        def available_filters_with_gm_filters
          return @available_filters if @available_filters

          trackers = project.nil? ? Tracker.find(:all, :order => 'position') : project.rolled_up_trackers

          @available_filters = { "status_id" => { :type => :list_status, :order => 1, :values => IssueStatus.find(:all, :order => 'position').collect{|s| [s.name, s.id.to_s] } },
                                 "tracker_id" => { :type => :list, :order => 2, :values => trackers.collect{|s| [s.name, s.id.to_s] } },
                                 "priority_id" => { :type => :list, :order => 3, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] } },
                                 "subject" => { :type => :text, :order => 8 },
                                 "created_on" => { :type => :date_past, :order => 9 },
                                 "updated_on" => { :type => :date_past, :order => 10 },
                                 "start_date" => { :type => :date, :order => 11 },
                                 "due_date" => { :type => :date, :order => 12 },
                                 "estimated_hours" => { :type => :integer, :order => 13 },
                                 "done_ratio" =>  { :type => :integer, :order => 14 }}

          user_values = []
          user_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
          if project
            user_values += project.users.sort.collect{|s| [s.name, s.id.to_s] }
          else
            all_projects = Project.visible.all
            if all_projects.any?
              # members of visible projects
              user_values += User.active.find(:all, :conditions => ["#{User.table_name}.id IN (SELECT DISTINCT user_id FROM members WHERE project_id IN (?))", all_projects.collect(&:id)]).sort.collect{|s| [s.name, s.id.to_s] }

              # project filter
              project_values = []
              Project.project_tree(all_projects) do |p, level|
                prefix = (level > 0 ? ('--' * level + ' ') : '')
                project_values << ["#{prefix}#{p.name}", p.id.to_s]
              end
              @available_filters["project_id"] = { :type => :list, :order => 1, :values => project_values} unless project_values.empty?
            end
          end
          @available_filters["assigned_to_id"] = { :type => :list_optional, :order => 4, :values => user_values } unless user_values.empty?
          @available_filters["author_id"] = { :type => :list, :order => 5, :values => user_values } unless user_values.empty?

          group_values = Group.all.collect {|g| [g.name, g.id.to_s] }
          @available_filters["member_of_group"] = { :type => :list_optional, :order => 6, :values => group_values } unless group_values.empty?

          role_values = Role.givable.collect {|r| [r.name, r.id.to_s] }
          @available_filters["assigned_to_role"] = { :type => :list_optional, :order => 7, :values => role_values } unless role_values.empty?


          if User.current.logged?
            # ilya
            # @available_filters["watcher_id"] = { :type => :list, :order => 15, :values => [["<< #{l(:label_me)} >>", "me"]] }
            @available_filters["watcher_id"] = { :type => :list, :order => 15, :values => user_values }
            # /ilya
          end

          if project
            # project specific filters
            categories = @project.issue_categories.all
            unless categories.empty?
              @available_filters["category_id"] = { :type => :list_optional, :order => 6, :values => categories.collect{|s| [s.name, s.id.to_s] } }
            end
            versions = @project.shared_versions.all
            unless versions.empty?
              @available_filters["fixed_version_id"] = { :type => :list_optional, :order => 7, :values => versions.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] } }
            end
            unless @project.leaf?
              subprojects = @project.descendants.visible.all
              unless subprojects.empty?
                @available_filters["subproject_id"] = { :type => :list_subprojects, :order => 13, :values => subprojects.collect{|s| [s.name, s.id.to_s] } }
              end
            end
            add_custom_fields_filters(@project.all_issue_custom_fields)
          else
            # global filters for cross project issue list
            system_shared_versions = Version.visible.find_all_by_sharing('system')
            unless system_shared_versions.empty?
              @available_filters["fixed_version_id"] = { :type => :list_optional, :order => 7, :values => system_shared_versions.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] } }
            end
            add_custom_fields_filters(IssueCustomField.find(:all, :conditions => {:is_filter => true, :is_for_all => true}))
          end

          # ilya
          @available_filters["gm_responsible_id"] = { :type => :list, :order => 5, :values => user_values } unless user_values.empty?
          # /ilya

          @available_filters
        end
      end
    
      module ClassMethods
      end

    end
  end
end
