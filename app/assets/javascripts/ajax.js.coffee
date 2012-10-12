gitstars.ajax =
  init: ->
    gitstars.ajax.bindBehaviors()

    $.ajaxSetup({dataType: "html"})
    $("[data-spinner]").ajaxStart(->
      $($(this).data("spinner")).removeClass("hide")
    ).ajaxStop(->
      $($(this).data("spinner")).addClass("hide")
    )

  bindBehaviors: ->
    $("[data-remote=true]").live "ajax:success", gitstars.ajax.success
    $("[data-remote=true]").live "ajax:error", gitstars.ajax.error
    $("[data-remote=true]").live "ajax:complete", gitstars.ajax.complete

  updateContent: (newContent) ->
    return unless $.trim(newContent)
    $(newContent).filter("[data-content-key]").each (index, elem) ->
      $elem = $(elem)
      contentKey = $elem.data("content-key")
      $("[data-content-key=" + contentKey + "]").html($elem.html()).trigger("content-updated")

    $(document).trigger("content-updated")

  updateFlashContent: (json) ->
#    flash = $.parseJSON(json)
#    $flashContainer = $("#flashes")
#    $successDiv = $flashContainer.find(".alert-success")
#    $errorDiv = $flashContainer.find(".alert-error")
#    if flash.notice
#      $errorDiv.html ""
#      $successDiv.html flash.notice
#      $successDiv.addClass $successDiv.data("alert-class")
#      gbo.delayedFade $successDiv
#    else if flash.alert
#      $successDiv.html ""
#      $errorDiv.html flash.alert
#      $errorDiv.addClass $errorDiv.data("alert-class")
#      gbo.delayedFade $errorDiv

  success: (event, data, status, xhr) ->
    gitstars.ajax.updateContent data

  error: (event, xhr) ->
    gitstars.ajax.updateContent xhr.responseText

  complete: (event, xhr) ->
#    @updateFlashContent xhr.getResponseHeader("X-Flash-Messages")
