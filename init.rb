require 'redmine'


Redmine::Plugin.register :redmine_greenmine do
  name 'Redmine Greenmine plugin'
  author 'Ilya Nemihin'
  description 'This is a plugin for Redmine'
  version '0.0.5'
  url 'https://github.com/nemilya/redmine_greenmine'
  author_url ''

  project_module :issue_tracking do
    permission(:issue_move_up_down, {})
  end

end

require 'issues_helper_patch'
require 'application_helper_patch'
require 'redmine_export_pdf_patch' # overwrite base class


require 'dispatcher'
Dispatcher.to_prepare :redmine_greenmine do

  require_dependency 'issue'
  Issue.safe_attributes "gm_responsible_id"
  Issue.send(:include, RedmineGreenmine::Patches::IssuePatch)
end


require 'redmine_greenmine/hooks/view_issues_show_details_bottom_hook'
require 'redmine_greenmine/hooks/view_issues_form_details_bottom_hook'

