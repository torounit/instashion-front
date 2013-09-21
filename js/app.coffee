#
# App
# jQuery
# jQuery.bottom-1.0
#
#

log = (args...)->
  console?.log(args...)
  args[0]


do ($ = jQuery) ->

  class App
    constructor:() ->
      @loading = false
      @POSTS_PER_PAGE = 2
      @JSON_URL = "http://api.usergrid.com/meriiken/instashion/movies"
      #@JSON_URL = "/simplejson.json"

      @page = 0
      @options = @getOptions()
      @el = @getEl()
      @setPlugin()
      @entries = new Entries(@)

      @el.window.on "jsonLoaded" , =>

        @delegator = new Delegator(@)
        @delegator.on()
        @el.window.trigger("bottom")


    getOptions:() ->
      {
        hello: "world"
      }

    setPlugin:() ->
      @el.window.bottom() #jquery bottom

    getEl:() ->
      {
        window: $ window
        document: $ document
        hoge: $ ".hoge"
        container: $ "#postContainer"
      }



  class Delegator
    constructor:(@app) ->

    on:() ->
      @app.el.window.on "bottom" ,@loadContents
      @app.el.document.on "click", ".tag" ,@tagSelect

    loadContents:() =>
      @app.entries.getEntries();

    tagSelect:() =>
      @app.entries.reset()

  class Entries
    constructor:(@app,@entries) ->
      @page = 0
      @lock == false
      @jsondata;
      $.getJSON( @app.JSON_URL )
      .done (data) =>
        @jsondata = data
        @entries = data.entities #投稿データ。
        @app.el.window.trigger("jsonLoaded")

    reset:() =>
      @app.el.container.html("")
      @page = 0;
      $(window).scrollTop(0);

    getEntries:() =>
      log @entries
      @render @entries.slice(@page* @app.POSTS_PER_PAGE, (@page+1)* @app.POSTS_PER_PAGE )
      @page = @page + 1;


    render:(entries) =>

      items = []
      $.each entries, (key, val) =>
        ytID = @parseYouTubeID(val.url)
        ins_imgs = val.instagram_images
        instagram = ""
        for photo in val.instagram_images
          instagram += """
              <div class="col-lg-4 col-xs-6">
                  <h2>Heading</h2>
                  <p><a href="#{photo.url}"><img src="#{photo.img}" width="100" height="100"></a></p>
              </div>
            """




        items.push """
          <div class="col-6 col-sm-6 col-sm-6-height col-lg-4 col-xs-6">
              <h2>#{val.title}</h2>
              <div class="row entry">
                  <p class="frame_youtube">
                      <a href="https://youtube.googleapis.com/v/#{ytID}?rel=0" class="youtube-movie"><img src="http://img.youtube.com/vi/#{ytID}/0.jpg" alt=""></a>
                  </p>
                  <p>
                      <a class="btn btn-primary" href="#">View details ≫</a>
                  </p>

                  <div class="row">
                  #{instagram}

                  </div>
              </div>
          </div>
        """




      @app.el.container.append(items.join(""))


    parseYouTubeID:(url) =>
      elm = document.createElement('a');
      elm.href = 'http://www.youtube.com/watch?v=Q16KpquGsIc&gl=JP&hl=ja#coment'
      elm.href = url
      params = elm.search.substring(1).split('&')
      id = params[0].substring(2)



  $ ->
    instashion = new App()



