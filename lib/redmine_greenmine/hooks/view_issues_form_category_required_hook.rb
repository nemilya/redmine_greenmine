module RedmineGreenmine
  module Hooks
    class ViewIssuesFormCategoryRequiredHook < Redmine::Hook::ViewListener
      render_on(:view_issues_form_details_bottom, :partial => 'issues/form_category_required', :layout => false)
    end
  end
end
