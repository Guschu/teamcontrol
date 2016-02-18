module ApplicationHelper
  def nav_link_to(*args, &block)
    link = block_given? ? link_to(*args, &block) : link_to(*args)
    url = block_given? ? args[0] : args[1]
    content_tag :li, link, :class=>(current_page?(url) ? 'active' : nil)
  end

  # data: { confirm: t('messages.confirm_delete'), ok: t('buttons.ok'), cancel: t('buttons.cancel')
  # = link_to [@race, team], :method => :delete, data:{ confirm:t(:confirm) } do
  #   = fa_icon 'trash fw'
  #   = t(:destroy)

  def destroy_link_to(url)
    content = fa_icon('trash fw') + t('destroy')
    link_to content, url, :method => :delete, data:{ confirm:t('confirm'), ok:t('buttons.ok'), cancel:t('buttons.cancel') }
  end

  def time_format(time)
    time.strftime('%H:%M:%S')
  end
end
