module ApplicationHelper
  def nav_link_to(*args, &block)
    link = block_given? ? link_to(*args, &block) : link_to(*args)
    url = block_given? ? args[0] : args[1]
    content_tag :li, link, :class=>(current_page?(url) ? 'active' : nil)
  end
end
