local config = require("tailwind-tools.config")

return {
  conceal = {
    enabled = false,
    active_buffers = {},
  },
  color = {
    request_timer = nil,
    enabled = config.options.document_color.enabled,
    active_buffers = {},
  },
}
