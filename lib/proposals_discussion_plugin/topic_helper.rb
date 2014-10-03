module ProposalsDiscussionPlugin::TopicHelper

  def topic_title(topic)
    content_tag(:div, '', :class=>'topic-color', :style => "background-color: #{topic.color};") +
      content_tag(:h2, link_to(topic.title, topic.view_url))
  end

end
