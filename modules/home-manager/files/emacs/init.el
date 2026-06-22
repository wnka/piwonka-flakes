;;; init.el --- Phil's vanilla Emacs config -*- lexical-binding: t; -*-

;; A fresh, fast, from-scratch config replacing the old DOOM setup.
;; Goals: quick startup, markdown, Rust with completion (Eglot), and Magit.
;; Plus the keybindings my fingers can't live without.

;;; ---------------------------------------------------------------------------
;;; Package system + use-package
;;; ---------------------------------------------------------------------------

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

;; `use-package' is built in since Emacs 29.  Make it install missing packages
;; automatically so a fresh machine bootstraps itself on first launch.
(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t)

;;; ---------------------------------------------------------------------------
;;; Sensible defaults
;;; ---------------------------------------------------------------------------

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      use-short-answers t                 ; y/n instead of yes/no
      sentence-end-double-space nil
      require-final-newline t)

;; Keep the home dir / config dir tidy: stash auto-saves and backups elsewhere.
;; Create the directories if missing so auto-save/backup never fail on a fresh
;; machine.
(let ((backup-dir (expand-file-name "backups" user-emacs-directory))
      (auto-save-dir (expand-file-name "auto-save/" user-emacs-directory)))
  (make-directory backup-dir t)
  (make-directory auto-save-dir t)
  (setq backup-directory-alist `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,auto-save-dir t))
        create-lockfiles nil))

;; From the old config: kill the whole line including newline.
(setq kill-whole-line t)

;; Line wrapping preferences carried over from DOOM config.
(setq-default truncate-lines nil
              truncate-partial-width-windows nil)

;; UI niceties
(setq display-line-numbers-type t)
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(save-place-mode 1)                       ; remember point in visited files
(global-auto-revert-mode 1)               ; reflect on-disk changes
(setq auto-revert-verbose nil)

;; Persist minibuffer history across sessions (was in old config).
(use-package savehist
  :ensure nil                             ; built-in
  :init (savehist-mode 1))

;;; ---------------------------------------------------------------------------
;;; Look: font + theme + modeline
;;; ---------------------------------------------------------------------------

(when (member "Berkeley Mono" (font-family-list))
  (set-face-attribute 'default nil :family "Berkeley Mono" :height 150))

;; DOOM's themes as a standalone package (no DOOM required).  This is the same
;; theme I used in my old DOOM config: doom-feather-dark.  Browse others with
;; `M-x load-theme' (e.g. doom-one, doom-tokyo-night, doom-gruvbox, ...).
(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-feather-dark t)
  (doom-themes-org-config))   ; nicer org fontification, harmless elsewhere

;; Icon fonts used by doom-modeline (and usable elsewhere).  Run
;; `M-x nerd-icons-install-fonts' ONCE so the glyphs render instead of tofu.
(use-package nerd-icons)

;; The DOOM modeline.  Tweaks carried over from the old DOOM config.
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 30)
  (doom-modeline-persp-name t))

;; Startup splash screen (the successor to DOOM's doom-dashboard).  Shows
;; recent projects, recent files, and the org agenda.  Uses nerd-icons (above).
(use-package dashboard
  :init (dashboard-setup-startup-hook)
  :custom
  (dashboard-items '((projects . 8)
                     (recents  . 8)
                     (agenda   . 5)))
  (dashboard-projects-backend 'project-el)   ; use built-in project.el
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  ;; NOTE: the agenda section stays empty until `org-agenda-files' is set
  ;; (deferred to the org setup session).
  (dashboard-week-agenda t))

;;; ---------------------------------------------------------------------------
;;; Minibuffer / completion stack: vertico + orderless + marginalia + consult
;;; ---------------------------------------------------------------------------

(use-package vertico
  :init (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package consult
  :bind (("C-s" . consult-line)           ; old muscle memory: C-s = consult-line
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ;; Project-aware commands (the projectile-style pickers from DOOM),
         ;; living under the native `C-x p' project.el prefix.
         ;; NOTE: `C-x p f' is intentionally left as project.el's own
         ;; `project-find-file' (set below), which preloads the full project
         ;; file list so files show immediately and you narrow by typing.
         ;; consult-fd/consult-find are async and stay empty until you type,
         ;; which is NOT the projectile-style behavior we want for file finding.
         ("C-x p g" . consult-ripgrep)    ; grep across the project (uses rg)
         ("C-x p b" . consult-project-buffer)))

;;; ---------------------------------------------------------------------------
;;; Projects: built-in project.el (modern, lightweight projectile replacement)
;;; ---------------------------------------------------------------------------

;; project.el ships with Emacs and binds its commands under `C-x p':
;;   C-x p f  find file in project      C-x p p  switch project
;;   C-x p g  ripgrep in project        C-x p b  switch project buffer
;;   C-x p d  dired at project root     C-x p c  compile
;; Projects are detected by VCS, so every git repo just works with no config.
;; `C-x p f' stays project-find-file (instant full file list + type-to-narrow);
;; the consult bindings above enhance g (ripgrep) and b (buffers).
(use-package project
  :ensure nil)                            ; built-in

;;; ---------------------------------------------------------------------------
;;; In-buffer completion: corfu + cape (pairs with Eglot)
;;; ---------------------------------------------------------------------------

(use-package corfu
  :init (global-corfu-mode 1)
  :custom
  (corfu-auto t)                          ; popup completions as you type
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-cycle t))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;;; ---------------------------------------------------------------------------
;;; Markdown
;;; ---------------------------------------------------------------------------

;; Default .md to the full-featured MELPA `markdown-mode'.  Emacs 31 also ships
;; a built-in tree-sitter `markdown-ts-mode' (just `M-x markdown-ts-mode' to try
;; it); its `markdown' + `markdown-inline' grammars are installed under
;; tree-sitter/.  The grammar source recipes auto-register when that mode loads.
(use-package markdown-mode
  :mode (("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook (markdown-mode . turn-off-auto-fill))  ; carried over from DOOM config

;; The built-in markdown-ts-mode.el ships WITHOUT autoload cookies, so `M-x'
;; can't find the command until the file is loaded.  `:commands' makes
;; use-package create the autoload so `M-x markdown-ts-mode' just works.
(use-package markdown-ts-mode
  :ensure nil                             ; built-in
  :commands (markdown-ts-mode))

;;; ---------------------------------------------------------------------------
;;; Rust: built-in tree-sitter mode + Eglot (lightweight LSP)
;;; ---------------------------------------------------------------------------

;; Where to fetch grammars from via `treesit-install-language-grammar'.
;; NOTE: these versions are pinned for ABI compatibility with the
;; locally-built tree-sitter 0.22.6 library (supports grammar ABI 13-14).
;; The current grammar `master' branches compile to ABI 15 and will NOT load.
(setq treesit-language-source-alist
      '((rust       "https://github.com/tree-sitter/tree-sitter-rust" "v0.21.2")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript")
        (json       "https://github.com/tree-sitter/tree-sitter-json" "v0.21.0")
        (python     "https://github.com/tree-sitter/tree-sitter-python" "v0.21.0")
        (bash       "https://github.com/tree-sitter/tree-sitter-bash" "v0.21.0")))

;; Use the tree-sitter Rust mode for .rs files.
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))

(use-package eglot
  :ensure nil                             ; built-in since Emacs 29
  :hook ((rust-ts-mode . eglot-ensure))
  :config
  ;; Use clippy for on-save checking, matching the old lsp-mode preference.
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode) .
                 ("rust-analyzer" :initializationOptions
                  (:check (:command "clippy")))))
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)))

;;; ---------------------------------------------------------------------------
;;; Git: Magit
;;; ---------------------------------------------------------------------------

(use-package magit
  :bind (("C-x g" . magit-status)))

(defalias 'gits 'magit-status)            ; old alias

;;; ---------------------------------------------------------------------------
;;; Other languages & data formats (carried over from DOOM :lang modules)
;;; ---------------------------------------------------------------------------

;; Nix.  I write Nix regularly (this flake), so this is high value.
(use-package nix-mode
  :mode "\\.nix\\'")

;; Data formats.
(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

(use-package toml-mode
  :mode ("\\.toml\\'" . toml-mode))

;; JSON via the built-in tree-sitter mode (grammar pinned above).
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-ts-mode))

;; Fish shell scripts (I use fish as my shell).
(use-package fish-mode
  :mode ("\\.fish\\'" . fish-mode))

;; Python & JavaScript via built-in tree-sitter modes.  The JS grammar is
;; already installed; the python grammar is pinned in the source list above.
;; Eglot will start if the relevant language server is on PATH (pyright/
;; pylsp for Python, typescript-language-server for JS) -- harmless if absent.
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))
(add-hook 'python-ts-mode-hook #'eglot-ensure)
(add-hook 'js-ts-mode-hook #'eglot-ensure)

;;; ---------------------------------------------------------------------------
;;; Quality-of-life (things DOOM gave me for free)
;;; ---------------------------------------------------------------------------

;; which-key: popup of available keybindings after a prefix.  Built in since
;; Emacs 30, so no package download needed.
(use-package which-key
  :ensure nil
  :init (which-key-mode 1)
  :custom (which-key-idle-delay 0.5))

;; diff-hl: VCS change indicators in the fringe (the old `vc-gutter' module).
(use-package diff-hl
  :init (global-diff-hl-mode 1)
  :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)))

;;; ---------------------------------------------------------------------------
;;; Terminal: Kitty Keyboard Protocol support
;;; ---------------------------------------------------------------------------

;; Ghostty (TERM=xterm-ghostty) and other modern terminals enable the Kitty
;; keyboard protocol, which encodes keys like C-n as "ESC [ 110 ; 5 u".  Emacs
;; doesn't negotiate that protocol on its own, so it mis-parses held/repeated
;; keys and leaks the ";5u" tail into the buffer.  `kkp' makes Emacs speak the
;; protocol properly (no-op in the GUI, where it isn't needed).
(use-package kkp
  :config
  (global-kkp-mode 1)
  ;; With the Kitty protocol active, `_' (which is Shift-`-') no longer
  ;; collapses to the single byte Emacs reads as C-_.  Instead Emacs sees
  ;; C-S-- (control-shift-minus), so the classic `C-_' undo binding misses.
  ;; Bind the decoded variant explicitly so undo works in the terminal.
  (keymap-global-set "C-S--" #'undo)

  ;; Likewise, kkp delivers Escape as the distinct `<escape>' key symbol
  ;; rather than the raw ESC byte, so the old `ESC ESC ESC' escape-quit no
  ;; longer fires (and a stray Escape reports "ESC <escape> is undefined").
  ;; Bind <escape> straight to keyboard-escape-quit so a SINGLE Escape bails
  ;; out of pickers / sub-buffers / the minibuffer.
  (keymap-global-set "<escape>" #'keyboard-escape-quit))

;;; ---------------------------------------------------------------------------
;;; Navigation: avy
;;; ---------------------------------------------------------------------------

(use-package avy
  :custom (avy-all-windows t)
  :bind (("C-\\" . avy-goto-char-timer)
         ("M-\\" . avy-goto-char-timer)))

;;; ---------------------------------------------------------------------------
;;; Muscle-memory keybindings carried over from the old DOOM config
;;; ---------------------------------------------------------------------------

;; Pull up M-x more easily.
(global-set-key (kbd "C-x C-m") #'execute-extended-command)
(global-set-key (kbd "C-x m")   #'execute-extended-command)

;; Jump around lists/parens easily.
(global-set-key (kbd "M-n") #'forward-list)
(global-set-key (kbd "M-p") #'backward-list)

;; Handy aliases from the old config.
(defalias 'qrr 'query-replace-regexp)
(defalias 'edb 'ediff-buffers)
(defalias 'afm 'auto-fill-mode)

;;; ---------------------------------------------------------------------------
;;; Keep customizations out of init.el
;;; ---------------------------------------------------------------------------

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;;; init.el ends here
