module ProposalsDiscussionPlugin::TopicHelper

  def topic_title(topic)
    return if topic.blank?
    image_icon = topic.image ?  image_tag(topic.image.public_filename(:thumb), :class => 'disable-zoom') : ''

    content_tag(:div, (
      content_tag(:div, '', :class=>'topic-color', :style => "background-color: #{topic.color};") +
        content_tag(:h2, link_to(image_icon + content_tag(:span, topic.title), topic.view_url))
    ), :class => 'topic-title')
  end

end
