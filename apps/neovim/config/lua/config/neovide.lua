local M = {}

local default_guifont = table.concat({
  "JetBrainsMono Nerd Font Mono",
  "Maple Mono NF CN",
  "CaskaydiaCove Nerd Font",
}, ",") .. ":h13:#e-subpixelantialias:#h-slight"

local function set_ime(args)
  vim.g.neovide_input_ime = args.event:match("Enter$") ~= nil
end

if vim.g.neovide then
  vim.o.guifont = (vim.o.guifont ~= "" and vim.o.guifont) or default_guifont
  vim.opt.linespace = 1

  vim.g.neovide_theme = "light"
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor or 1.0
  vim.g.neovide_pixel_geometry = "RGBH"
  vim.g.neovide_text_gamma = 0.8
  vim.g.neovide_text_contrast = 0.12

  vim.g.neovide_padding_top = 8
  vim.g.neovide_padding_bottom = 8
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10

  vim.g.neovide_position_animation_length = 0.12
  vim.g.neovide_scroll_animation_length = 0.16
  vim.g.neovide_scroll_animation_far_lines = 1

  vim.g.neovide_cursor_animation_length = 0.07
  vim.g.neovide_cursor_short_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.55
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line = true
  vim.g.neovide_cursor_unfocused_outline_width = 0.12
  vim.g.neovide_cursor_smooth_blink = true
  vim.g.neovide_cursor_vfx_mode = "pixiedust"
  vim.g.neovide_cursor_vfx_opacity = 180.0
  vim.g.neovide_cursor_vfx_particle_lifetime = 0.35
  vim.g.neovide_cursor_vfx_particle_density = 0.55
  vim.g.neovide_cursor_vfx_particle_speed = 8.0

  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_message_area_drag_selection = false
  vim.g.neovide_refresh_rate = 120
  vim.g.neovide_refresh_rate_idle = 10
  vim.g.neovide_no_idle = false
  vim.g.neovide_confirm_quit = true
  vim.g.neovide_detach_on_quit = "always_quit"
  vim.g.neovide_remember_window_size = true
  vim.g.neovide_profiler = false

  vim.g.neovide_opacity = 0.96
  vim.g.neovide_normal_opacity = 0.98
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 12
  vim.g.neovide_light_angle_degrees = 38
  vim.g.neovide_light_radius = 4
  vim.g.neovide_floating_blur_amount_x = 2.4
  vim.g.neovide_floating_blur_amount_y = 2.4
  vim.g.neovide_floating_corner_radius = 0.24
  vim.g.neovide_title_background_color = "#fafafa"
  vim.g.neovide_title_text_color = "#383a42"
  vim.g.neovide_corner_preference = "round"
  vim.g.neovide_progress_bar_enabled = true
  vim.g.neovide_progress_bar_height = 3.0
  vim.g.neovide_progress_bar_animation_speed = 180.0
  vim.g.neovide_progress_bar_hide_delay = 0.25

  local ime_group = vim.api.nvim_create_augroup("QintsgNeovideIme", { clear = true })
  vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    group = ime_group,
    pattern = "*",
    callback = set_ime,
  })
  vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
    group = ime_group,
    pattern = "[/\\?]",
    callback = set_ime,
  })
end

function M.scale(delta)
  if not vim.g.neovide then
    return
  end
  local next_scale = math.max(0.6, math.min(2.0, (vim.g.neovide_scale_factor or 1.0) + delta))
  vim.g.neovide_scale_factor = next_scale
end

function M.reset_scale()
  if not vim.g.neovide then
    return
  end
  vim.g.neovide_scale_factor = 1.0
end

function M.toggle_fullscreen()
  if not vim.g.neovide then
    return
  end
  vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end

return M

