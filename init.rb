require 'redmine'

require 'issues_helper_patch'
require 'application_helper_patch'
require 'redmine_export_pdf_patch' # overwrite base class

Redmine::Plugin.register :redmine_greenmine do
  name 'Redmine Greenmine plugin'
  author 'Ilya Nemihin'
  description 'This is a plugin for Redmine'
  version '0.0.4'
  url 'https://github.com/nemilya/redmine_greenmine'
  author_url ''
end

require 'dispatcher'
Dispatcher.to_prepare :redmine_greenmine do

  require_dependency 'issue'
  Issue.safe_attributes "gm_responsible_id"
  Issue.send(:include, RedmineGreenmine::Patches::IssuePatch)
end


require 'redmine_greenmine/hooks/view_issues_show_details_bottom_hook'
require 'redmine_greenmine/hooks/view_issues_form_details_bottom_hook'

