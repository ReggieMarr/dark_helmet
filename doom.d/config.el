;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Reg Marr"
      user-mail-address "reginald.t.marr@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "monospace" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-vibrant)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.
;; (use-package "fzf" :init (setenv "FZF_DEFAULT_COMMAND" "fd --type f"))


;; Prettify symbols
(global-prettify-symbols-mode +1)
(use-package lsp-mode
  :config
  (add-hook 'c++-mode-hook #'lsp)
  (add-hook 'python-mode-hook #'lsp)
  (add-hook 'rust-mode-hook #'lsp))
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; LSP For C/C++ (ccls)
;(require 'ccls)
;(setq ccls-executable "CCLS_PATH")
;(use-package lsp-mode :commands lsp)
;(use-package lsp-ui :commands lsp-ui-mode)
;(use-package company-lsp :commands company-lsp)
;
;(use-package ccls
;  :hook ((c-mode c++-mode objc-mode cuda-mode) .
;         (lambda () (require 'ccls) (lsp))))
(use-package lsp-mode :commands lsp)
(use-package lsp-ui
  ;; flycheck integration & higher level UI modules
  :commands lsp-ui-mode)

(use-package company-lsp
  ;; company-mode completion
  :commands company-lsp
  :config (push 'company-lsp company-backends))

(use-package lsp-treemacs
  ;; project wide overview
  :commands lsp-treemacs-errors-list)

(use-package dap-mode
  :commands (dap-debug dap-debug-edit-template))
(require 'dap-python)

;Doesn't work yet, have to figure out why
;(use-package ccls
;  :ensure t
;  :config
;  (setq ccls-exectuable "/home/rmarr/.local/bin/ccls")
;  :hook ((c-mode) . (lambda () (require 'ccls) (lsp)))
;  )
