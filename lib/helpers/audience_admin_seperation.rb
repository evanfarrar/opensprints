module AudienceAdminSeperation
  module InstanceMethods
    def admin_window?; !owner; end
    def audience_window?; !admin_window?; end
    def audience_friendly_url?(url); $audience_visible_urls.any? { |re| url =~ re }; end
  end
  module ClassMethods
    def audience_friendly_urls(*urls)
      $audience_visible_urls ||= []
      $audience_visible_urls += urls
    end
  end
end
