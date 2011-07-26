module RedmineAdvancedIssueHistory
  module Hooks
    class ControllerIssuesEditAfterSaveHook < Redmine::Hook::ViewListener
      # Context:
      # * :issue => Issue being saved
      # * :params => HTML parameters
      #
      def controller_issues_edit_after_save(context={})
        issue = context[:issue]
        params = context[:params]
        status = issue.status
        if status.is_closed?
          issue.descendants.each do |child|
            child.status = status
            child.save
          end
        end
      end
    end
  end
end
