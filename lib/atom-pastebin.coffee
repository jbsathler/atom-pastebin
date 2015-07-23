{CompositeDisposable} = require 'atom'
shell = require 'shell'
http = require 'http'
https = require 'https'
settings = require './settings'

module.exports = AtomPastebin =
  config: settings.config

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-pastebin:upload_public': () => @upload_public()
      'atom-pastebin:upload_private': () => @upload_private()

    @transport = @get_transport()

  # Returns an object with the text and title for the current active editor
  get_editor_data: ->
    editor = atom.workspace.getActivePane().getActiveEditor()
    data =
      text: editor.getText()
      title: editor.getTitle()
    return data

  # Returns the current config for atom pastebin
  get_config: ->
    return atom.config.get('atom-pastebin')

  # Use HTTPS by default, else use HTTP
  get_transport: ->
    if @get_config().use_https is true
      return require 'https'
    else
      return require 'http'

  # Check config to decide whether to open the paste in the browser, and/or
  # to copy the URL to the clipboard
  finalize: (config, url) ->
    if config.copy_paste_to_clipboard is true
      atom.clipboard.write url
    if config.open_paste_in_browser is true
      shell.openExternal url

  upload_public: ->
    config = @get_config()
    data = @get_editor_data()
    query = @build_query(config, data, "public")
    @api_request(config, query)

  upload_private: ->
    config = @get_config()
    data = @get_editor_data()
    query = @build_query(config, data, "private")
    @api_request(config, query)

  # Build the Pastebin API query string
  build_query: (config, data, visibility) ->
    if visibility is "public" then vis = 0
    else if visibility is "private" then vis = 2

    query = "api_option=paste" +
      "&api_dev_key=#{encodeURIComponent config.developer_key}" +
      "&api_paste_private=#{encodeURIComponent vis}" +
      "&api_paste_expire_date=#{encodeURIComponent config.expire_len}" +
      "&api_paste_name=#{encodeURIComponent data.title}" +
      "&api_paste_code=#{encodeURIComponent data.text}"

  api_request: (config, query) ->
    options =
      host: config.api_url
      path: config.api_path
      method: 'POST'
      headers:
        'Content-Type': 'application/x-www-form-urlencoded',

    resp = ""
    req = @transport.request options, (res) =>
      res.setEncoding "utf8"
      # Accumulate the response data
      res.on "data", (chunk) -> resp += chunk
      # On end, check for error, or call finalize with the response
      res.on "end", =>
        if resp.toLowerCase().indexOf("bad api request") >= 0
          alert "ERROR: " + resp
        else
          @finalize(config, resp)
    # Write the query to the Pastebin API
    req.write query
    req.end()
