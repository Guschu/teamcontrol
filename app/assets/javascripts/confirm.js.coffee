# confirm
$ ->
  $.rails.allowAction = (link) ->
    return true unless link.attr('data-confirm')
    $.rails.showConfirmDialog(link)
    false

  $.rails.confirmed = (link) ->
    link.removeAttr('data-confirm')
    link.trigger('click.rails')

  $.rails.showConfirmDialog = (link) ->
    message = link.attr 'data-confirm'
    html = """
      <div class="modal fade" id="confirmationDialog" tabindex="-1" role="dialog">
        <div class="modal-dialog">
          <div class="modal-content">
            <div class="modal-header">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
              <h4 class="modal-title">#{message}</h4>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn" data-dismiss="modal">#{link.data('cancel')}</button>
              <button type="button" class="btn btn-primary confirm">#{link.data('ok')}</button>
            </div>
          </div>
        </div>
      </div>
    """
    $(html).modal()
    $(document).on 'click', '#confirmationDialog .confirm', -> $.rails.confirmed(link)
