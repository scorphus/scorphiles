#!/bin/bash
# macos.sh: sets the macOS preferences this setup expects. Safe to run twice.
# Most take effect at the next login; the Dock and Finder ones right away.
# The com.apple.universalaccess lines fail unless the terminal has Full Disk Access.
set -eu

# Nested values are kept whole, one file per key in macos/:
#   --save   read them off this Mac into macos/, change nothing else
NESTED="com.apple.symbolichotkeys AppleSymbolicHotKeys
NSGlobalDomain NSUserDictionaryReplacementItems
com.apple.HIToolbox AppleEnabledInputSources"
DIR=$(dirname "$0")/macos

if [ "${1:-}" = --save ]; then
    mkdir -p "$DIR"
    while read -r domain key; do
        defaults export "$domain" - | plutil -extract "$key" xml1 -o "$DIR/$key.plist" -
    done <<<"$NESTED"
    exit
fi

# --- Keyboard ---

# Caps Lock is Escape (built-in keyboard)
defaults -currentHost write -g com.apple.keyboard.modifiermapping.0-0-0 -array \
    '<dict><key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer><key>HIDKeyboardModifierMappingDst</key><integer>30064771113</integer></dict>'

# fastest key repeat, shortest delay before it starts
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Tab moves through all controls, not only text boxes and lists
defaults write -g AppleKeyboardUIMode -int 2

# --- Trackpad ---

# tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

# drag with three fingers; the swipes between spaces and to Mission Control take four
for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
    defaults write $domain TrackpadThreeFingerDrag -bool true
    defaults write $domain TrackpadThreeFingerHorizSwipeGesture -int 0
    defaults write $domain TrackpadThreeFingerVertSwipeGesture -int 0
    defaults write $domain TrackpadFourFingerHorizSwipeGesture -int 2
    defaults write $domain TrackpadFourFingerVertSwipeGesture -int 2
done

# Ctrl + scroll zooms the screen
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask -int 262144

# --- Pointer and display ---

# pointer: lime outline, dark green fill, a bit larger than normal
defaults write com.apple.universalaccess cursorIsCustomized -bool true
defaults write com.apple.universalaccess cursorOutline -dict red -float 0.098 green -float 1 blue -float 0.098 alpha -float 1
defaults write com.apple.universalaccess cursorFill -dict red -float 0.0196 green -float 0.196 blue -float 0.0118 alpha -float 1
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.4

defaults write com.apple.universalaccess reduceTransparency -bool true
defaults write com.apple.universalaccess speakSelectionEnabled -bool true

# dark windows and dark app icons
defaults write -g AppleInterfaceStyle Dark
defaults write -g AppleIconAppearanceTheme RegularDark

# US English with Germany's formats for dates, numbers and currency
defaults write -g AppleLocale 'en_US@rg=dezzzz'

# --- Dock, windows, menu bar ---

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 41
defaults write com.apple.dock largesize -int 73

# ⌘Tab shows on every display
defaults write com.apple.dock appswitcher-all-displays -bool true

# hot corners: top left Mission Control (2), bottom left Lock Screen (13), bottom right nothing (1)
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-bl-corner -int 13
defaults write com.apple.dock wvous-br-corner -int 1

# tiled windows touch each other and the screen edges
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# menu bar icons packed tight, so more of them fit beside the notch
defaults -currentHost write -g NSStatusItemSpacing -int 0
defaults -currentHost write -g NSStatusItemSelectionPadding -int 0

# --- Finder ---

# list view, with the path bar and the status bar
defaults write com.apple.finder FXPreferredViewStyle Nlsv
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# --- Power ---

# display and system sleep after 5 minutes; low power mode on battery
sudo pmset -a displaysleep 5 sleep 5
sudo pmset -b lowpowermode 1

# --- Nested values ---

# system shortcuts turned off, text replacements, keyboard layouts
while read -r domain key; do
    defaults write "$domain" "$key" "$(cat "$DIR/$key.plist")"
done <<<"$NESTED"

killall Dock Finder
