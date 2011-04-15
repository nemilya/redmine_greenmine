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
end