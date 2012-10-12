window.gitstars = window.gitstars || {
  views: {},

  init: ->
    gitstars.ajax.init()
    @bindBehaviors()
  ,

  bindBehaviors: ->
    @initializeTagSearchField()
    @autoCloseAlerts()
  ,

  autoCloseAlerts: ->
    $alertDiv = $("#flashes .alert")

    if ($alertDiv)
      setTimeout(->
        $alertDiv.alert('close')
      , 1500)
  ,

  initializeTagSearchField: ->
    $tagSearchField = $("#tag-search-field")
    $tagSearchField.tokenInput($tagSearchField.data("remote-url"), {
      theme: 'gitstars',
      prePopulate: $tagSearchField.data("load"),
      hintText: null,
      animateDropdown: true,
      preventDuplicates: true,
      tokenLimit: 4
    })

  handleTagEditing: ->
    # handle cancel link on repo list edit tags
    $("#repo-lists").on "click", ".lnk-cancel", (event) ->
      event.preventDefault()

      $cancelLink = $(this)
      $editTagsContainer = $cancelLink.closest("form").parent()
      $editLink = $editTagsContainer.siblings(".edit-tags")
      $tagList = $editLink.siblings("ol")

      $tagList.toggle()
      $editTagsContainer.toggle()
      $editLink.toggle()


    # handle edit tags link on repo list view
    $("#repo-lists").on "click", ".edit-tags", (event) ->
      event.preventDefault()

      $editLink = $(this)
      $editTagsContainer = $editLink.siblings(".edit-tags-form")
      $tagList = $editLink.siblings("ol")
      $editTagsField = $editTagsContainer.find("input[type=text]")
      $cancelLink = $editTagsContainer.find(".lnk-cancel")

      #console.log $editTagsContainer.data('token-input-initialized')
      if(!$editTagsContainer.data("token-input-initialized"))
        #console.log('>>> initializing tokeninput')
        $editTagsField.tokenInput($editTagsField.data("remote-url"), {
          theme: 'gitstars',
          prePopulate: $editTagsField.data("load"),
          hintText: null,
          animateDropdown: true,
          preventDuplicates: true,
          tokenLimit: 7
        })
      $editTagsContainer.data("token-input-initialized", true)
      #console.log $editTagsContainer.data('is-token-input-initialized')

      $tagList.toggle()
      $editTagsContainer.toggle()
      $editLink.toggle()
      $editTagsField.focus()

}
