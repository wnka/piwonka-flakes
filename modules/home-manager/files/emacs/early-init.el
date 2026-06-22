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

;; Point `custom-file' at custom.el NOW, before any package installs.  package.el
;; saves `package-selected-packages' via Customize whenever it installs something
;; (notably a `use-package :vc' clone), and if `custom-file' is still nil at that
;; point it falls back to writing into `user-init-file' -- which here is a
;; read-only Nix-store symlink, so the write fails with "chmod: Operation not
;; permitted".  Setting it here (before init.el's package blocks run) sends that
;; write to custom.el instead.  init.el still loads custom.el at its tail.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; Avoid a flash of unstyled UI: disable chrome before the frame is created.
(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Don't resize the frame when fonts/UI change during startup.
(setq frame-inhibit-implied-resize t)

;;; early-init.el ends here
