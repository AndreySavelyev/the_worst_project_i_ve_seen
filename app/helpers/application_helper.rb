module ApplicationHelper

  include GlobalConstants

  def comments_as_json(comments)
    comments.collect do |comment|
      {
         # :id => comment.id,
         # :level => comment.level,
         # :content => html_format(comment.content),
         # :parent_id => comment.parent_id,
         # :user_id => comment.user_id,
         # :created_at => comment.created_at
      }
    end.to_json
  end

  def self.get_domain_name

    domain = GlobalConstants::DOMAIN_NAME[:development]

    if Rails.env == 'test'
      domain = GlobalConstants::DOMAIN_NAME[:test]
    end

    if Rails.env == 'production'
      domain = GlobalConstants::DOMAIN_NAME[:production]
    end

    domain

  end

end
