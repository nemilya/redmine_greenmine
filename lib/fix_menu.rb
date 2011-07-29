module Redmine
  module MenuManager
    module MenuHelper
      def allowed_node?(node, user, project)
        # ilya
        if node.url == { :controller => 'issues', :action => 'new' }
          return false if !user.allowed_to?(:add_issues, @project)
        end
        # /ilya

        if node.condition && !node.condition.call(project)
          # Condition that doesn't pass
          return false
        end

        if project
          return user && user.allowed_to?(node.url, project)
        else
          # outside a project, all menu items allowed
          return true
        end
      end
    end
  end
end