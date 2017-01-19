(package-initialize)

(when window-system (tool-bar-mode -1)
      (menu-bar-mode -1)
      (set-frame-size (selected-frame) 120 40))

(when (require 'color-theme)
  (color-theme-initialize)
  (when (require 'color-theme-solarized)
    (color-theme-solarized-dark)))

(setq delete-auto-save-files t)
(setq make-backup-files nil)

(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)