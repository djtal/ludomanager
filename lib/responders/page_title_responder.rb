module Responders
  module PageTitleResponder
    def to_html
      set_page_title!
      super
    end

    protected

    def set_page_title!
      controller.instance_variable_set('@page_title', I18n.t("#{controller.controller_name}.#{controller.action_name}.page_title"))
    end

  end
end
