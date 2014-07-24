module ApplicationHelper
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

end
