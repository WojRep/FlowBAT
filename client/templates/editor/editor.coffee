share.EditorCache =
  editors: {}
  register: (editor) ->
    @editors[editor.family] = editor
  editorId: (family, _id) ->
    family + ":" + _id
  editorKey: (family, _id, key) ->
    family + "-" + _id + "-" + key
  getSessionValue: (subkey) ->
    Session.get(subkey + "-editors") or {}
  setSessionValue: (subkey, value) ->
    Session.set(subkey + "-editors", value)
  add: (editorId, subkey, info) ->
    bag = @getSessionValue(subkey)
    bag[editorId] = info
    @setSessionValue(subkey, bag)
  remove: (editorId, subkey) ->
    bag = @getSessionValue(subkey)
    delete bag[editorId]
    @setSessionValue(subkey, bag)
  stopEditing: (exceptEditorId) ->
    for editorId, info of @getSessionValue("is-edited") when editorId isnt exceptEditorId
      @editors[info.family].stopEditing(info._id)

class share.Editor
  constructor: (options) ->
    _.extend(@, options)
  editorId: (_id) ->
    share.EditorCache.editorId(@family, _id)
  editorKey: (_id, key) ->
    share.EditorCache.editorKey(@family, _id, key)
  insert: (object = {}, callback = ->) ->
    _id = @collection.insert(object, callback)
    @startEditing(_id)
    _id
  isEdited: (_id) ->
    Session.equals(@family + "-" + _id + "-is-edited", true)
  startEditing: (_id) ->
    Session.set(@editorKey(_id, "is-edited"), true)
    share.EditorCache.add(@editorId(_id), "is-edited", {family: @family, _id: _id})
  stopEditing: (_id) ->
    Session.set(@editorKey(_id, "is-edited"), false)
    share.EditorCache.remove(@editorId(_id), "is-edited")

share.MeetingEditor = new share.Editor(
  collection: share.Meetings
  family: "meeting"
)
share.EditorCache.register(share.MeetingEditor)

share.createExtension = ->
  share.stopEditingExtension()
  extensionId = Extensions.insert({})
  if extensionId
    extension = Extensions.findOne(extensionId)
    #    Session.set(extension.htmlId() + "-is-open", true)
    Session.set("editedExtensionProperty", "name")
    Session.set("isEditedExtensionModal", true)
    Session.set("editedExtensionHtmlId", extension.htmlId())
    Session.set("editedExtensionId", extensionId)
    share.setUrlAndOpenExtensionModal(extensionId)

share.saveEditedExtension = (stopEditing = false) ->
  editedObjectId = Session.get("editedExtensionId")
  editedObject = share.Extensions.findOne(editedObjectId)
  if editedObjectId
    $editors = $(".extension[data-id='" + editedObjectId + "'] .property-editor")
    $set = {}
    if stopEditing
      $set.isNew = false
    $editors.each (index, editor) ->
      $editor = $(editor)
      name = $editor.attr("name")
      value = $editor.val()
      if stopEditing
        value = value.trim()
      if name is "execUrls"
        execUrls = value.match(share.linkRegExp) || []
        value = []
        for execUrl in execUrls
          execUrl = execUrl.trim()
          if not execUrl.match(/^#/i) # comments
            value.push(execUrl)
      if not _.isEqual(editedObject[name], value)
        $set[name] = value
    if not _.isEmpty($set)
      Extensions.update(editedObjectId, {$set: $set})

share.stopEditingExtension = (forceRemovalNewEmptyExtension = false) ->
  extension = Extensions.findOne(Session.get("editedExtensionId"))
  isNew = extension?.isNew # will change upon save
  share.saveEditedExtension(true)
  extension = Extensions.findOne(Session.get("editedExtensionId")) # refresh
  if extension?.isEmpty()
    if forceRemovalNewEmptyExtension and isNew
      Extensions.remove(extension._id)
      Session.set("editedExtensionId", null)
      Session.set("editedExtensionHtmlId", null)
    else
      # noop
  else
    Session.set("editedExtensionId", null)
    Session.set("editedExtensionHtmlId", null)

share.debouncedSaveEditedExtension = _.debounce(share.saveEditedExtension, 1000)
