gitstars.views.users = {

  init: ->
    #@bindBehaviors()
  ,

  bindBehaviors: ->
  ,

  initShow: ->
    gitstars.handleTagEditing()
    @pollLatestRepos()
  ,

  pollLatestRepos: ->
    remoteUrl = $("header#first-signin").data("remote-url")

    if remoteUrl
      $.ajax({
        url: remoteUrl,
        type: "GET",
        dataType: "html",
        success: gitstars.views.users.handleLatestRepos
      })
  ,

  handleLatestRepos: (data) ->
    if data == "pending"
      setTimeout(gitstars.views.users.pollLatestRepos, 1000)
    else
      $(".main").html(data)
      gitstars.handleTagEditing()
  ,

}
