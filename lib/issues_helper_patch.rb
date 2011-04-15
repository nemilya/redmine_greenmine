require_dependency 'issues_helper'
module IssuesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :render_descendants_tree, :move
    end
  end

  module InstanceMethods
    def render_descendants_tree_with_move(issue)
    s = '<form><table class="list issues">'
    issue_list(issue.descendants.sort_by(&:lft)) do |child, level|
      link_up = '<span style="color: #e0e0e0">up</span>'
      if child.left_sibling
        link_up = '<a href="/greenmine/issue_move/'+child.id.to_s+'?move=up&back_issue_id='+issue.id.to_s+'">up</a>'
      end

      link_down = '<span style="color: #e0e0e0">down</span>'
      if child.right_sibling
        link_down = '<a href="/greenmine/issue_move/'+child.id.to_s+'?move=down&back_issue_id='+issue.id.to_s+'">down</a>'
      end
      tr_style = nil
      #if flash[:moved_issue_id] && flash[:moved_issue_id].to_i == child.id
      if params[:moved_issue_id] && params[:moved_issue_id].to_i == child.id
        tr_style = 'background-color: #FFFF99'
      end
      s << content_tag('tr',
             content_tag('td', check_box_tag("ids[]", child.id, false, :id => nil), :class => 'checkbox') +
             content_tag('td', link_to_issue(child, :truncate => 60), :class => 'subject') +
             content_tag('td', h(child.status)) +
             content_tag('td', link_up + ' ' + link_down ) +
             content_tag('td', link_to_user(child.assigned_to)) +
             content_tag('td', progress_bar(child.done_ratio, :width => '80px')),
             :class => "issue issue-#{child.id} hascontextmenu #{level > 0 ? "idnt idnt-#{level}" : nil}",
             :style => tr_style
             )
    end
    s << '</form></table>'
    s
    end
  end
end

IssuesHelper.send(:include, IssuesHelperPatch)