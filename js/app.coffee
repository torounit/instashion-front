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
      @LIMIT = 100
      @POSTS_PER_PAGE = 2
      @JSON_URL = "http://api.usergrid.com/meriiken/instashion/movies"
      #@JSON_URL = "./dummyjson.json"

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
        genreSelectors: $("#genreSelector").find(".dropdown-menu a");
      }



  class Delegator
    constructor:(@app) ->

    on:() ->
      @app.el.window.on "bottom" ,@loadContents
      #@app.el.document.on "click", ".tag" ,@tagSelect
      @app.el.genreSelectors.on "click", @genreSelect

    loadContents:() =>
      @app.entries.getEntries();

    tagSelect:() =>
      @app.entries.reset()

    genreSelect:(e) =>
      e.preventDefault()
      target = e.currentTarget
      tag = target.dataset.tag
      q = ""
      if(tag)
        q += "tag='"+tag+"'"
        console.log q
      @app.entries.reset(q)

  class Entries
    constructor:(@app,@entries) ->
      @reset();

    reset:(q = "") =>
      $(window).scrollTop(0);
      @page = 0
      @jsondata;
      $.getJSON( @app.JSON_URL , { limit: @app.LIMIT,ql: q})
      .done (data) =>
        @jsondata = data
        @app.el.container.html("")
        @entries = data.entities #投稿データ。
        @lock == false
        @app.el.window.trigger("jsonLoaded")


    getEntries:() =>
      console.log @entries
      @render @entries.slice(@page* @app.POSTS_PER_PAGE, (@page+1)* @app.POSTS_PER_PAGE )
      @page = @page + 1;


    render:(entries) =>

      items = []
      $.each entries, (key, val) =>
        ytID = @parseYouTubeID(val.url)
        ins_imgs = val.instagram_images
        instagram = ""
        if ins_imgs
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
                      <a href="https://youtube.googleapis.com/v/#{ytID}?rel=0" class="youtube-movie thumbnail"><img src="http://img.youtube.com/vi/#{ytID}/0.jpg" alt=""></a>
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



