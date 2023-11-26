local bufferline = require('bufferline')

bufferline.setup({
  options = {
    mode = "tabs",
    style_preset = bufferline.style_preset.default,
    themable = true,
    numbers = 'none',
    indicator = {
      style = 'none',
    },
    buffer_close_icon = '󰅖',
    modified_icon = '',
    close_icon = '󰅖',
    left_trunc_marker = '',
    right_trunc_marker = '',
    name_formatter = function(buf)
      return buf.name
    end,
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    truncate_names = true,  -- whether or not tab names should be truncated
    tab_size = 15,
    diagnostics = false,    -- Or "nvim_lsp"
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local debug = false
      if debug then
        vim.print(vim.inspect(context))
      end

      if level == "error" then
        return tostring(diagnostics_dict.error)
      elseif level == "warning" then
        return tostring(diagnostics_dict.warning)
      else
        return ""
      end
    end,
    -- NOTE: this will be called a lot so don't do any heavy processing here
    custom_filter = function(buf_number, buf_numbers)
    end,
    color_icons = false,
    get_element_icon = function(element)
    end,
    show_buffer_icons = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
    show_tab_indicators = false,
    enforce_regular_tabs = true,
  }
})
