-- shortcut panel, from Michael Borisov's dotfiles
-- https://github.com/SecTedd/dotfiles
--
-- Licensed under the MIT license:
-- http://www.opensource.org/licenses/mit-license
-- Copyright (c) 2026 Michael Borisov
--
-- ⌃⌥⌘/: the shortcut panel, a searchable list of every shortcut.
--
--   type          filter (fzf, fuzzy and ranked; keys also by name: "ctrl l", "cmd space", "enter")
--   ⌃J ⌃K ⌃N ⌃P   move (arrows work too)
--   ⏎ / click     run it. Hammerspoon: the action; tmux: the keys go to your active
--                 tmux client; fish (and copy-mode keys): copied to the clipboard
--   Esc, click outside, ⌃⌥⌘/   close
--
-- Files
--   panel.lua            this: the window (hs.webview), its JS bridge, show/hide, ⏎
--   panel/panel.html     the page: card, search field with count, list, footer
--   panel/entries.lua    collects the entries (Hammerspoon hotkeys, tmux, fish)
--   panel/search.lua     fzf --filter over the entries + modifier/key-aware ranking
--   panel/keys.lua       key labels: parsing, search words, query hints
--   panel/tmux.lua       tmux bindings read live, key presses sent to the active client
--   panel/fish.lua       fish key bindings (by hand) and abbreviations (read live)
--
-- The window is created at load and shown/hidden, so opening is instant. Unused
-- for IDLE_RELEASE seconds it is released again, with its WebKit process
-- (30-100 MB); the next open creates it anew (~0.1 s). It opens centered on the
-- screen of the active window; sizes are fixed numbers shared with the page
-- (nothing is measured at run time).

local hotkey = require("Modules/hotkey")
local entries = require("Modules/panel/entries")
local search = require("Modules/panel/search")

local M = {}

local HTML = hs.configdir .. "/Modules/panel/panel.html"

-- Layout in pixels; the page gets the same numbers (placeholders in panel.html)
local LAYOUT = {
  ROW_H = 34, MAX_ROWS = 14, HEADER_H = 48, FOOTER_H = 30,
  MARGIN = 40,        -- transparent border around the card, room for its shadow
  MAX_WIDTH = 820,    -- card width: WIDTH_PERCENT of the screen, at most this (14" MacBook: 756)
  WIDTH_PERCENT = 50,
  TOP_PERCENT = 22,   -- card top at this share of the screen height (Spotlight-like)
}
local FOCUS_DELAY = 0.03 -- s between showing the window and focusing the search field
local RUN_DELAY = 0.05   -- s between giving the focus back and running the chosen action
local IDLE_RELEASE = 600 -- s unused after which the window and its WebKit process are released

---------------------------------------------------------------------------
-- State of one opening

local index = nil    -- search index over the current entries (search.index)
local previous = nil -- window or app that had the focus before the panel opened
local pageReady = false -- panel.html finished loading in the current window
local pendingShow = false -- open as soon as the page is ready
local idleTimer = nil

local function js(code)
  M.webview:evaluateJavaScript(code)
end

local createWindow -- defined below (needs hide/show)

-- What the page needs per entry (no functions)
local function pageEntries()
  local out = {}
  for i, e in ipairs(index.entries) do
    out[i] = {
      index = e.index, key = e.key, description = e.description, group = e.group,
      icon = e.icon and e.icon:encodeAsURLString(false, "PNG") or nil,
      iconTemplate = e.iconTemplate or false,
    }
  end
  return out
end

local function showResults(list)
  local indices = {}
  for i, e in ipairs(list) do indices[i] = e.index end
  js("panelSetResults(" .. hs.json.encode(indices) .. ")")
end

-- Frame on the screen of the active window
local function place()
  local win = hs.window.frontmostWindow()
  local screen = (win and win:screen()) or hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
  local sf = screen:frame()
  local cardW = math.min(LAYOUT.MAX_WIDTH, math.floor(sf.w * LAYOUT.WIDTH_PERCENT / 100))
  local cardH = LAYOUT.HEADER_H + LAYOUT.MAX_ROWS * LAYOUT.ROW_H + LAYOUT.FOOTER_H
  local w, h = cardW + 2 * LAYOUT.MARGIN, cardH + 2 * LAYOUT.MARGIN
  M.webview:frame({
    x = sf.x + math.floor((sf.w - w) / 2),
    y = sf.y + math.floor(sf.h * LAYOUT.TOP_PERCENT / 100) - LAYOUT.MARGIN,
    w = w, h = h,
  })
  js("document.documentElement.style.setProperty('--width', '" .. cardW .. "px')")
end

local function focusPrevious()
  if previous and previous.focus then
    previous:focus()
  elseif previous and previous.activate then
    previous:activate()
  end
  previous = nil
end

-- Release the window when it hasn't been used for a while (memory), recreate on demand
function M.release()
  if idleTimer then idleTimer:stop(); idleTimer = nil end
  if M.webview and not M.webview:isVisible() then
    M.webview:delete()
    M.webview, pageReady, index = nil, false, nil
  end
end

local function releaseWhenIdle()
  if idleTimer then idleTimer:stop() end
  idleTimer = hs.timer.doAfter(IDLE_RELEASE, M.release)
end

-- Have the window and its page ready (created at load, and again after a release)
function M.warm()
  if M.webview then return end
  createWindow()
  releaseWhenIdle()
end

-- Hide, give the focus back, then (once the focus has moved) run something
local function hide(afterwards)
  if not M.webview or not M.webview:isVisible() then return end
  js("panelHide()") -- reset the page while it still renders (a hidden webview defers scripts)
  M.webview:hide()
  focusPrevious()
  if afterwards then hs.timer.doAfter(RUN_DELAY, afterwards) end
  releaseWhenIdle()
end

local function show()
  M.warm()
  if not pageReady then pendingShow = true; return end -- shown by the navigation callback
  if idleTimer then idleTimer:stop(); idleTimer = nil end
  previous = hs.window.frontmostWindow() or hs.application.frontmostApplication()
  index = search.index(entries.all())
  js("panelSetEntries(" .. hs.json.encode(pageEntries()) .. ")")
  showResults(index.entries)
  place()
  M.webview:show()
  local win = M.webview:hswindow()
  if win then win:focus() else hs.application.get("org.hammerspoon.Hammerspoon"):activate() end
  -- the field can take the focus once the window is key, a moment later
  hs.timer.doAfter(FOCUS_DELAY, function() js("panelShow()") end)
end

function M.toggle()
  if M.webview and M.webview:isVisible() then hide() else show() end
end

---------------------------------------------------------------------------
-- Messages from the page

local function run(i)
  local e = index and index.entries[i]
  if not e then return end
  if e.run then
    hide(e.run)
  elseif e.copy then
    hs.pasteboard.setContents(e.copy)
    hide()
    hs.alert.show("Copied: " .. e.copy, 1)
  else
    hide()
  end
end

local bridge = hs.webview.usercontent.new("panel"):setCallback(function(message)
  local body = message.body or {}
  if body.action == "query" then
    search.query(index, tostring(body.text or ""), showResults)
  elseif body.action == "run" then
    run(tonumber(body.index))
  elseif body.action == "close" then
    hide()
  end
end)

---------------------------------------------------------------------------
-- The window

local function pageHtml()
  local f = assert(io.open(HTML, "r"), "panel.html missing: " .. HTML)
  local html = f:read("a")
  f:close()
  return (html:gsub("__(%u[%u_]*)__", function(name)
    if name == "CARD_W" then return tostring(LAYOUT.MAX_WIDTH) end
    return tostring(LAYOUT[name] or ("__" .. name .. "__"))
  end))
end

createWindow = function()
  local w = hs.webview.new({ x = 0, y = 0, w = 100, h = 100 }, { developerExtrasEnabled = false }, bridge)
  w:windowStyle({ "borderless" })
  w:transparent(true):shadow(false) -- the card draws its own shadow, so it shrinks with the list
  w:level(hs.drawing.windowLevels.modalPanel)
  w:behavior(hs.drawing.windowBehaviors.moveToActiveSpace)
  w:allowTextEntry(true):allowGestures(false):allowNewWindows(false):deleteOnClose(false)
  w:windowCallback(function(action, _, state)
    if action == "focusChange" and state == false then hide() end -- a click outside closes it
  end)
  w:navigationCallback(function(action)
    if action == "didFinishNavigation" then
      pageReady = true
      if pendingShow then pendingShow = false; show() end
    end
  end)
  M.webview = w
  w:html(pageHtml())
end

M.warm()

M.hotkey = hotkey.bind({ "ctrl", "alt", "cmd" }, "/", "Shortcut panel: search all shortcuts", { "help" }, M.toggle)

return M
