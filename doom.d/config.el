(setq user-full-name "Eric Dyer"
      user-mail-address "dyereh@gmail.com"

      doom-scratch-initial-major-mode 'lisp-interaction-mode
      doom-theme 'doom-monokai-classic
      ;;treemacs-width 32 ;;TODO

      ;; Improve performance & disable line #'s by defausdlt
      display-line-numbers-type nil
)

(require 'package)

(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t) ;;Globally ensure that a package will be automatically installed

(use-package vterm
  :load-path  "/home/edyer/Desktop/emacs-libvterm")

(use-package symbol-overlay)

(use-package nov)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

(map! :leader
  (:prefix "w"
    :desc "Open vterm" "t"    #'vterm)
  (:prefix "b"
    :desc "Switch to buffer" "b" #'switch-to-buffer)
  (:prefix "f"
    :desc "Find file in projects" "f" #'projectile-find-file-in-known-projects)
  :desc "Switchhh" "a" #'switch-to-buffer)


;; LATEX
(setq +latex-viewrs '(pdf-tools))

(defun latex-compile ()
    (interactive)
    (save-buffer)
    (TeX-command "LaTeX" 'TeX-master-file))

(eval-after-load 'latex
  '(define-key TeX-mode-map (kbd "C-c C-g") 'latex-compile))
