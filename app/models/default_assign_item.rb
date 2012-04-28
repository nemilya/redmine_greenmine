class DefaultAssignItem < ActiveRecord::Base

  belongs_to :project
  belongs_to :assigned_to, :class_name => 'Principal', :foreign_key => 'assigned_to_id'

  # [category_id][tracket_id] :: object
  def self.get_matrix
    ret = {}
    DefaultAssignItem.find(:all).each do |item|
      ret[item.issue_category_id] ||= {}
      ret[item.issue_category_id][item.tracker_id] = item
    end
    ret
  end

  def self.get_assigned_for_issue(issue)
    project_id = issue.project.id
    tracker_id = issue.tracker.id rescue nil
    category_id = issue.category.id rescue nil
    if project_id && tracker_id && category_id
      item = DefaultAssignItem.find(:first, :conditions=>["project_id=? AND issue_category_id=? AND tracker_id=?", project_id, category_id, tracker_id])
      return item.assigned_to if item
    end
    nil
  end
  
end
