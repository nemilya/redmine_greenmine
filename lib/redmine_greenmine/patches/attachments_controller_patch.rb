module RedmineGreenmine
  module Patches
    module AttachmentsControllerPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          alias_method_chain :delete_authorize, :attachment_permission
          unloadable
        end
      end

      module ClassMethods
      end

      module InstanceMethods

        def delete_authorize_with_attachment_permission
          # @attachment.deletable? ? true : deny_access
          return true if @attachment.deletable?
          return true if @attachment.container.is_a?(Issue) \
                         && User.current.allowed_to?(:issue_edit_attachments, @project)
          deny_access
        end

      end
    end
  end
end
