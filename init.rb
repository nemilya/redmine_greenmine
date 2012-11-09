require 'redmine'

# Hooks
require_dependency 'greenmine_issue_hook'

Redmine::Plugin.register :redmine_greenmine do
  name 'Redmine Greenmine plugin'
  author 'Ilya Nemihin'
  description 'This is a plugin for Redmine'
  version '0.0.13'
  url 'https://github.com/nemilya/redmine_greenmine'
  author_url ''


  permission :assing_matrix, { :greenmine=> [:assign_matrix] }, :public => false

  menu(:project_menu,
         :assing_matrix,
         {:controller => 'greenmine', :action => 'assign_matrix'},
         :param => 'project_id',
         :caption => 'Матрица назначенных',
         :if => Proc.new { |p| User.current.admin? || User.current.allowed_to?(:assing_matrix, p) }
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

  Query.available_columns << QueryColumn.new(:gm_responsible, :sortable => lambda {User.fields_for_order_statement}, :groupable => true)
  Query.send(:include, RedmineGreenmine::Patches::QueryPatch)

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
require 'redmine_greenmine/hooks/view_issues_form_category_required_hook'
require 'redmine_greenmine/hooks/view_issues_form_details_bottom_hook'
require 'redmine_greenmine/hooks/controller_issues_edit_after_save_hook'
