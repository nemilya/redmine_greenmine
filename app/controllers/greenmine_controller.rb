class GreenmineController < ApplicationController
  def issue_move
    issue = Issue.find(params[:id])
    if params[:move] == 'up'
      issue.move_left
    elsif params[:move] == 'down'
      issue.move_right
    end
    # flash[:moved_issue_id] = issue.id
    redirect_to :controller=>'issues', :action=>'show', :id=>params[:back_issue_id], :moved_issue_id => issue.id
  end


  #  create_table :default_assign_items do |t|
  #    t.column :project_id, :integer
  #    t.column :issue_category_id, :integer
  #    t.column :tracker_id, :integer
  #    t.column :assigned_to_id, :integer, :null => false
  #  end

  def assign_matrix
    prj_id = params[:project_id]
    @project = Project.find(prj_id)
    @issue_categories = IssueCategory.find(:all, :conditions=>["project_id=?", @project.id], :order=>"name")
    @trackers = @project.trackers
    # [category_id][tracket_id] :: object
    @matrix = DefaultAssignItem.get_matrix
  end

  def set_assign_matrix
    prj_id = params[:project_id]
    project = Project.find(prj_id)
    issue_category_id = params[:c_id]
    tracker_id = params[:t_id]
    assigned_to_id = params[:assigned_to_id].to_i

    item = DefaultAssignItem.find(:first, :conditions=>["project_id=? AND issue_category_id=? AND tracker_id=?", project.id, issue_category_id, tracker_id])

    if assigned_to_id > 0
      if item.nil?
        # create
        item = DefaultAssignItem.new
        item.project_id = project.id
        item.issue_category_id = issue_category_id
        item.tracker_id = tracker_id
      end
      item.assigned_to_id = assigned_to_id
      item.save
    elsif !item.nil?
      item.destroy
    end
    redirect_to :controller=>'greenmine', :action=>'assign_matrix', :project_id => project
  end

end