class GreenmineIssueHook  < Redmine::Hook::ViewListener

  def helper_issues_show_detail_after_setting(context = { })
    # TODO Later: Overwritting the caller is bad juju
    if context[:detail].prop_key == 'gm_responsible_id'
      user = User.find_by_id(context[:detail].value)
      context[:detail].value = user.name unless user.nil?

      user = User.find_by_id(context[:detail].old_value)
      context[:detail].old_value = user.name unless user.nil?
    end
    ''
  end
  
end