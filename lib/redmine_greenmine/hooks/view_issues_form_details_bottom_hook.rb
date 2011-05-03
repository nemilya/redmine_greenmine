module RedmineGreenmine
  module Hooks
    class ViewIssuesFormDetailsBottomHook < Redmine::Hook::ViewListener
      render_on(:view_issues_form_details_bottom, :partial => 'issues/edit_responsible', :layout => false)
    end
  end
end
