;;; early-init.el --- Loaded before package system and GUI -*- lexical-binding: t; -*-

;; Crank the GC threshold way up during startup, then restore a sane value
;; afterward.  This is the single biggest, cheapest startup-time win.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024)  ; 64MB
                  gc-cons-percentage 0.1)))

;; Don't let package.el initialize before init.el runs; we drive it ourselves.
(setq package-enable-at-startup nil)

;; Avoid a flash of unstyled UI: disable chrome before the frame is created.
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Don't resize the frame when fonts/UI change during startup.
(setq frame-inhibit-implied-resize t)

;;; early-init.el ends here
