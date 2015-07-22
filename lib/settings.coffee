module.exports =
  config:
    api_url:
      type: "string"
      default: "pastebin.com"
      description: "Pastebin's API URL"
    api_path:
      type: "string"
      default: "/api/api_post.php"
      description: "Pastebin's API path"
    developer_key:
      type: "string"
      default: ""
      description: "Your Pastebin developer key: Log in to Pastebin and \
      go to http://pastebin.com/api"
    expire_len:
      type: "string"
      default: "10M"
      description: "How long to keep pastes active"
    use_https:
      type: "boolean"
      default: true
      description: "Use HTTPS transport for pastes"
    copy_paste_to_clipboard:
      type: "boolean"
      default: false
      description: "Copy the URL for the new paste to the clipboard"
    open_paste_in_browser:
      type: "boolean"
      default: true
      description: "Open the URL for the new paste in the default web browser"
