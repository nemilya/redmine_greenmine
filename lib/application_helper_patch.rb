require_dependency 'application_helper'
module ApplicationHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :link_to_issue, :title
    end
  end

  module InstanceMethods
    def link_to_issue_with_title(issue, options={})
      title = nil
      subject = nil
      if options[:subject] == false
        title = truncate(issue.subject, :length => 60)
      else
        subject = issue.subject
        if options[:truncate]
          subject = truncate(subject, :length => options[:truncate])
        end
      end

      s = link_to "#{issue.tracker} ##{issue.id}", {:controller => "issues", :action => "show", :id => issue}, 
                                                   :class => issue.css_classes,
                                                   :title => title

      if subject
        if subject.ends_with?('...')
          s << ": <span title='#{h issue.subject}'>#{h subject}</span>" 
        else
          s << ": #{h subject}" 
        end
      end
      s = "#{h issue.project} - " + s if options[:project]
      s
    end
  end
end

IssuesHelper.send(:include, ApplicationHelperPatch)