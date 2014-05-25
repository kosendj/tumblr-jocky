class Dashboard
  posts: ko.observableArray()
  ajaxLock: false
  buffer: 20
  show:
    self: ko.observable()
  postInfo: ko.observable()
  currentBoard: "default"
  boards:
    default: "/api/dashboard"
    tjbu: "/api/tumblog?name=tjbu"

  constructor: ->
    @cookie = Reblogmonster.getCookie()

  initialize: ->
    _.bindAll @, "registerPrimaryBlog", "fetchDashboard", "pushPosts", "checkPosts", "start", "reblog", "like", "setting"

    if @cookie.username? and @cookie.token?
      @username = @cookie.username
      @token = @cookie.token
      @start()
    else
      location.href = "/login"

    $("article").on "click", (event)=>
      @nextPost() if event.pageX > $(window).width() - 200
      @prevPost() if event.pageX < 200

    @boards.self = "/api/tumblog?name=#{@username}"

  registerPrimaryBlog: (blog)->
    @primaryBlog = blog
    @primaryBlog.baseHostName = @primaryBlog.url.replace(/http:\/\//, "").replace(/\/$/, "")

  start: ->
    @posts.removeAll()
    $.getJSON @boards[@currentBoard],
      init: true
    , (posts)=>
      @pushPosts posts
      $(".post:first").removeClass("wait").addClass("current")
      $(".post:eq(1)").removeClass("wait").addClass("next")
      $(".loading").fadeOut()
      @postInfo @updatePostInfo()

  fetchDashboard: ->
    if @ajaxLock is false
      @ajaxLock = true
      $(".loading").show()
      $.getJSON @boards[@currentBoard],
        token: @token
        init: false
        sinceId: parseInt(parseInt(_.last(@posts()).id) - (((parseInt(_.first(@posts()).id) - parseInt(_.last(@posts()).id)) / @posts().length) * @buffer))
      , (posts)=>
        count = @pushPosts posts
        @buffer += 10 if count < 10
        $(".loading").fadeOut()
        @ajaxLock = false

  removePosts: -> @posts.removeAll()

  pushPosts: (posts)->
    count = 0
    for post in posts
      if post.type is "photo"
        if @posts().length > 0
          if post.id < _.last(@posts()).id
            @posts.push post
            count += 1
        else
          @posts.push post
    count

  reblog: ->
    $current = $(".current")
    $reblog = $(".reblog")
    $reblog.show()
    $.post "/api/post/#{$current.attr("data-id")}/reblog",
      reblogKey: $current.attr("data-reblogKey")
    , (data)->
      $reblog.hide()
      $(".finish").show().fadeOut()

  like: ->
    $current = $(".current")
    $like = $(".like")
    $like.show()
    $.post "/api/user/#{@username}/dashboard/like",
      token: @token
      id: $current.attr("data-id")
      reblogKey: $current.attr("data-reblogKey")
    , (data)->
      $like.hide()
      $(".finish").show().fadeOut()

  switchBoard: ->
    boards = Object.keys(@boards)
    for board, i in boards
      if board is @currentBoard
        if i < (boards.length-1)
          next = i + 1
        else
          next = 0
    @currentBoard = boards[next]
    console.log @currentBoard
    @start()

  checkPosts: ->
    @fetchDashboard() if $(".wait").length < 50

  setting: ->
    @settingView !@settingView()

  nextPost: ->
    $(".current:first").removeClass("current").addClass("done")
    $(".next:first").removeClass("next").addClass("current")
    $(".wait:first").removeClass("wait").addClass("next")
    @checkPosts()
    @postInfo @updatePostInfo()

  prevPost: ->
    if $(".done").length > 0
      $(".done:last").removeClass("done").addClass("current")
      $(".current:last").removeClass("current").addClass("next")
      $(".next:last").removeClass("next").addClass("wait")
      @postInfo @updatePostInfo()

  updatePostInfo: ->
    "#{$('.current').attr('data-blogName')}/#{$('.current').attr('data-notes')}notes"

do ->
  dsbd = new Dashboard()
  dsbd.initialize()
  ko.applyBindings dsbd
