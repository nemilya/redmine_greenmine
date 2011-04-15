require 'redmine'

require 'issues_helper_patch'

Redmine::Plugin.register :redmine_greenmine do
  name 'Redmine Greenmine plugin'
  author 'Ilya Nemihin'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/nemilya/redmine_greenmine'
  author_url ''
end