# A class-based template for jQuery plugins in Coffeescript
#
#     $('.target').myPlugin({ paramA: 'not-foo' });
#     $('.target').myPlugin('myMethod', 'Hello, world');
#
# Check out Alan Hogan's original jQuery plugin template:
# https://github.com/alanhogan/Coffeescript-jQuery-Plugin-Template
#
(($, window) ->

  # Define the plugin class
  class Timer

    defaults:
      mode: 'timer'  # timer or countdown
      show_seconds: true
      duration: 0    # required for countdown
      warning: 0     # triggers timer:warning when timer diff > value
      error: 0       # triggers timer:error when timer diff > value

    constructor: (el, options) ->
      @$el = $(el)
      @options = $.extend({}, @defaults, @$el.data(), options)
      @options.show_seconds = (@options.show_seconds == true || @options.show_seconds == 'true')
      @start = if @options.start? then @options.start else Date.now()
      $(document).on 'timer:heartbeat', $.proxy((evt, now) ->
          @update(now)
        , @)
      @update(Date.now())

    update: (now) ->
      current = if @options.current? then @options.current else now
      switch @options.mode
        when 'timer'
          diff = ((current - @start) / 1000) | 0
        when 'countdown'
          diff = @options.duration - (((current - @start) / 1000) | 0)

      negative = false
      if diff < 0
        diff = Math.abs diff
        negative = true

      if diff == 0
        hours = 0
        minutes = 0
        seconds = 0
      else
        hours   = (diff / 3600) | 0
        minutes = ((diff - hours * 3600) / 60) | 0
        seconds = (diff % 60) | 0

      hours   = if hours   < 10 then "0" + hours   else hours
      minutes = if minutes < 10 then "0" + minutes else minutes
      seconds = if seconds < 10 then "0" + seconds else seconds

      content = if negative then '-' else ''
      content += hours + ":" + minutes
      if @options.show_seconds
        content += ":" + seconds

      @$el.toggleClass 'negative', negative
      @$el.text content
      switch @options.mode
        when 'timer'
          if @options.error > 0 && diff >= @options.error
            @$el.trigger('timer:error', diff)
          else if @options.warning > 0 && diff >= @options.warning
            @$el.trigger('timer:warning', diff)
        when 'countdown'
          if diff <= @options.error
            @$el.trigger('timer:error', diff)
          else if @options.warning > 0 && diff <= @options.warning
            @$el.trigger('timer:warning', diff)

  # Define the plugin
  $.fn.extend timer: (option, args...) ->
    @each ->
      $this = $(this)
      data = $this.data('timer')

      if !data
        $this.data 'timer', (data = new Timer(this, option))
      if typeof option == 'string'
        data[option].apply(data, args)

) window.jQuery, window

$ ->
  $('.timer').timer()
  timerHeartbeat = setInterval(->
    $(document).trigger 'timer:heartbeat', Date.now()
  , 1000)
