require 'redmine'


Redmine::Plugin.register :redmine_greenmine do
  name 'Redmine Greenmine plugin'
  author 'Ilya Nemihin'
  description 'This is a plugin for Redmine'
  version '0.0.9'
  url 'https://github.com/nemilya/redmine_greenmine'
  author_url ''


  permission :assing_matrix, { :greenmine=> [:assign_matrix] }, :public => false

  menu(:project_menu,
         :assing_matrix,
         {:controller => 'greenmine', :action => 'assign_matrix'},
         :param => 'project_id',
         :caption => 'Матрица ответственных',
         :if => Proc.new { User.current.admin? }
      )



  project_module :issue_tracking do
    permission(:issue_move_up_down, {})
    permission(:issue_edit_start_date, {})
    permission(:issue_edit_due_date, {})
    permission(:issue_edit_priority, {})
    permission(:issue_edit_assigned_to, {})
    permission(:issue_edit_done_ratio, {})
    permission(:issue_edit_status, {})
    permission(:issue_edit_attachments, {})
    permission(:issue_edit_estimated_hours, {})
    permission(:issue_edit_fixed_version, {})
#    permission(:manage_subtasks, {:issues => [:new, :create]})
  end


  # remapping permissions
  Redmine::AccessControl.permissions.delete_if do |p|
    p.name == :manage_subtasks
  end
  project_module :issue_tracking do |map|
    map.permission :manage_subtasks,  {:issues => [:new, :create]}
  end

end

require 'issues_helper_patch'
require 'application_helper_patch'
require 'redmine_export_pdf_patch' # overwrite base class
require 'fix_menu'

require 'dispatcher'
Dispatcher.to_prepare :redmine_greenmine do

  require_dependency 'issue'
  Issue.safe_attributes "gm_responsible_id"


  ['start_date', 'due_date', 'priority', 'assigned_to', 'done_ratio', 'status', 'estimated_hours'].each do |f_name|
    Issue.safe_attributes f_name,
      :if => lambda {|issue, user| issue.new_record? || user.allowed_to?("issue_edit_#{f_name}".to_sym, issue.project) }
  end

  Issue.send(:include, RedmineGreenmine::Patches::IssuePatch)

  require_dependency 'attachments_controller'
  AttachmentsController.send(:include, RedmineGreenmine::Patches::AttachmentsControllerPatch)

end

require 'redmine_greenmine/hooks/view_issues_show_details_bottom_hook'
require 'redmine_greenmine/hooks/view_issues_form_details_bottom_hook'
require 'redmine_greenmine/hooks/controller_issues_edit_after_save_hook'
