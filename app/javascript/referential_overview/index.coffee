class TimeTravel
  constructor: (@overview)->
    @container = @overview.container.find('.time-travel')
    @todayBt = @container.find(".today")
    @prevBt = @container.find(".prev-page")
    @nextBt = @container.find(".next-page")
    @searchDateBt = @container.find("a.search-date")
    @searchDateInput = @container.find("input.date-search")
    @initButtons()

  initButtons: ->
    @prevBt.click (e)=>
      @overview.prevPage()
      e.preventDefault()
      false

    @nextBt.click (e)=>
      @overview.nextPage()
      e.preventDefault()
      false

    @todayBt.click (e)=>
      today = new Date()
      month = today.getMonth() + 1
      month = "0#{month}" if month < 10
      day = today.getDate()
      day = "0#{day}" if day < 10
      date = "#{today.getFullYear()}-#{month}-#{day}"
      @overview.showDay date
      @pushDate date
      e.preventDefault()
      false

    @searchDateBt.click (e)=>
      date = @searchDateInput.val()
      if @searchDateInput.val().length > 0
        @overview.showDay date
        @pushDate date

      e.preventDefault()
      false

  formatHref: (href, date)->
    param_name = "#{@overview.container.attr('id')}_date"
    href = href.replace new RegExp("[\?\&]#{param_name}\=[0-9\-]*"), ''
    if href.indexOf('?') > 0
      href += '&'
    else
      href += '?'
    href + "#{param_name}=#{encodeURIComponent date}"

  pushDate: (date)->
    location = @formatHref(document.location.pathname + document.location.search, date)
    window.history.pushState({}, "", location)
    for link in @overview.container.find('.pagination a')
      $link = $(link)
      $link.attr 'href', @formatHref($link.attr('href'), date)


  scrolledTo: (progress)->
    @prevBt.removeClass 'disabled'
    @nextBt.removeClass 'disabled'
    @prevBt.addClass 'disabled' if progress == 0
    @nextBt.addClass 'disabled' if progress == 1

class window.ReferentialOverview
  constructor: (selector)->
    @container = $(selector)
    @timeTravel = new TimeTravel(this)
    param_name = "#{@container.attr('id')}_date"
    date = new URL(document.location.href).searchParams.get(param_name)

    @currentOffset = 0
    $(document).scroll (e)=>
      @documentScroll(e)
    @documentScroll pageY: $(document).scrollTop()
    if date
      @showDay date

  showDay: (date)->
    day = @container.find(".day.#{date}")
    @container.find(".day.selected").removeClass('selected')
    day.addClass "selected"
    offset = day.offset().left
    parentOffset = @currentOffset + @container.find(".right").offset().left
    @scrollTo parentOffset - offset

  currentOffset: ->
    @container.find(".right .inner").offset().left

  top: ->
    @_top ||= @container.find('.days').offset().top - 80
  bottom: ->
    @_bottom ||= @top() + @container.height() - 50

  prevPage: ->
    @scrollTo @currentOffset + @container.find(".right").width()

  nextPage: ->
    @scrollTo @currentOffset - @container.find(".right").width()

  minOffset: ->
    @_minOffset ||= @container.find(".right").width() - @container.find(".right .line").width()
    @_minOffset

  scrollTo: (offset)->
    @currentOffset = offset
    @currentOffset = Math.max(@currentOffset, @minOffset())
    @currentOffset = Math.min(@currentOffset, 0)
    @container.find(".right .inner .lines").css "margin-left": "#{@currentOffset}px"
    @container.find(".head .week:first-child").css "margin-left", "#{@currentOffset}px"
    @timeTravel.scrolledTo 1 - (@minOffset() - @currentOffset) / @minOffset()
    setTimeout =>
      @movePeriodTitles()
    , 600

  movePeriodTitles: ->
    @_right_offset ||= @container.find('.right').offset().left
    @container.find(".shifted").removeClass("shifted").css "margin-left", 0
    @container.find(".right .line").each (i, l) =>
      $(l).find(".period").each (i, _p) =>
        p = $(_p)
        offset = parseInt(p.css("left")) + @currentOffset
        if offset < 0 && - offset < p.width()
          offset = Math.min(-offset, p.width() - 100)
          p.find(".title").addClass("shifted").css "margin-left", offset + "px"
          return

  documentScroll: (e)->
    if @sticky
      if e.pageY < @top() || e.pageY > @bottom()
        @container.removeClass "sticky"
        @sticky = false
    else
      if e.pageY > @top() && e.pageY < @bottom()
        @sticky = true
        @container.addClass "sticky"



export default ReferentialOverview
