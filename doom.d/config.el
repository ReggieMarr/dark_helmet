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

;; Add directory & descendant directories to load path
(let ((default-directory "~/dark_helmet/privatePlugins"))
(normal-top-level-add-subdirs-to-load-path))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t) ;;Globally ensure that a package will be automatically installed

;; VTERM
(use-package vterm
  :load-path  "/home/edyer/Desktop/emacs-libvterm")

(with-eval-after-load 'vterm
  '(define-key vterm-mode-map (kbd "M-j") 'vterm-send-down)
  '(define-key vterm-mode-map (kbd "M-k") 'vterm-send-up))

(defun open-named-terminal (termName2)
  (vterm)
  (rename-buffer termName2 t)
  (evil-normal-state))

(defun find-named-terminal (termName)
  (catch 'exit-find-named-terminal
    (if
        (string-match-p termName (buffer-name (current-buffer)))
        (bury-buffer (buffer-name (current-buffer))))

    (dolist (b (buffer-list))
      (if (string-match-p termName (buffer-name b))
          (progn
           (switch-to-buffer b)
           (throw 'exit-find-named-terminal nil))))

    (open-named-terminal termName))
  )
(defun find-std-terminal ()
  (interactive)
  (find-named-terminal "std-term"))

(defun open-std-terminal ()
  (interactive)
  (open-named-terminal "std-term"))

(defun find-maint-terminal ()
  (interactive)
  (find-named-terminal "maint-term"))

(defun open-maint-terminal ()
  (interactive)
  (open-named-terminal "maint-term"))

(map! :leader
      (:prefix "w"
        :desc "Open maint term"  "M"  #'open-maint-terminal
        :desc "Go to maint term" "m"  #'find-maint-terminal
        :desc "Open std term"    "T"  #'open-std-terminal
        :desc "Go to std term"   "t"  #'find-std-terminal))

(use-package symbol-overlay)

(use-package nov)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

(map! :leader
  ;; (:prefix "w"
    ;; :desc "Open vterm" "t"    #'vterm)
  (:prefix "b"
    :desc "Switch to buffer" "b" #'switch-to-buffer)
  (:prefix "f"
    :desc "Find file in projects" "f" #'projectile-find-file-in-known-projects)
  :desc "Switchhh" "a" #'switch-to-buffer)

;; NAVIGATION
(setq evil-scroll-count 5) ;; I like the scroll to be a bit more granular
(defun my/evil-scroll-down ()
  (interactive)
  (evil-scroll-down 10))

(defun my/evil-scroll-up ()
  (interactive)
  (evil-scroll-up 10))

(define-key evil-normal-state-map (kbd "C-d") #'my/evil-scroll-down)
(define-key evil-normal-state-map (kbd "C-u") #'my/evil-scroll-up)

;; LATEX
(setq +latex-viewrs '(pdf-tools))

(defun latex-compile ()
    (interactive)
    (save-buffer)
    (TeX-command "LaTeX" 'TeX-master-file))

(eval-after-load 'latex
  '(define-key TeX-mode-map (kbd "C-c C-g") 'latex-compile))

(with-eval-after-load 'evil-motion-state-map
  (define-key evil-motion-state-map (kbd "C-o") nil))

;;###########################
;;#          MAGIT          #
;;###########################
(define-suffix-command reset-upstream ()
  (interactive)
  (if (magit-confirm t (format "**WARNING** this will hard reset to upstream branch. Continue?"))
      (magit-run-git "add" "-A"))
  )
; fs
(define-suffix-command fixup-head ()
  "Make current commit a fixup to HEAD"
  (interactive)
  (magit-run-git "commit" "--fixup" "HEAD")
  )

(with-eval-after-load 'magit
  ;; Register custom keybindings

  ;; Navigation
  (define-key magit-mode-map (kbd "M-j") 'magit-section-forward)
  (define-key magit-mode-map (kbd "M-k") 'magit-section-backward)
  (define-key magit-mode-map (kbd "C-M-j") 'magit-section-forward-sibling)
  (define-key magit-mode-map (kbd "C-M-k") 'magit-section-backward-sibling)
  (define-key magit-mode-map (kbd "C-K") 'magit-section-up)

  ;; Section folding/expansion
  (define-key magit-mode-map (kbd "M-o") 'magit-section-toggle)
  (define-key magit-mode-map (kbd "C-o") 'magit-section-cycle)

  ;; Register Custom Commands
 (transient-append-suffix 'magit-commit "c"
                         '("h" "fixup head" fixup-head))

 (transient-append-suffix 'magit-reset "f"
                         '("u" "upstream" reset-upstream))
)

;; Automatically refresh status buffer
(add-hook 'after-save-hook 'magit-after-save-refresh-status t)

;; Prevent long refnames from hiding commit messages in the log
(setq magit-log-show-refname-after-summary t)
(setq magit-log-margin '(t age-abbreviated 15 t 10))

;; List of repositories
(setq magit-repository-directories
      ;; `(("~" . DEPTH1)))
      `(("~/release"      . 1)
        ("~/kinetis"      . 1)
        ("~/dark_helmet"  . 1)))
        ;; ("~/dark_helment" . DEPTH3)))

(setq magit-repolist-columns
      '(("Name"    25 magit-repolist-column-ident                  ())
        ("Version" 25 magit-repolist-column-version                ())
        ("D"        1 magit-repolist-column-dirty                  ())
        ("L<U"      3 magit-repolist-column-unpulled-from-upstream ((:right-align t)))
        ("L>U"      3 magit-repolist-column-unpushed-to-upstream   ((:right-align t)))
        ("Path"    99 magit-repolist-column-path                   ())))
;; Fun useless plugins

;; Weather Forcast
;;
;;;; weather from wttr.in
;; (use-package wttrin
  ;; :ensure t
  ;; :commands (wttrin)
  ;; :init
  ;; (setq wttrin-default-cities '("Hamilton"))
  ;; (setq wttrin-default-accept-language '("Accept-Language" . "en-US"))
  ;; )

;; (defun bjm/wttrin ()
    ;; "Open `wttrin' without prompting, using first city in `wttrin-default-cities'"
    ;; (interactive)
    ;; (wttrin-query (car wttrin-default-cities))
    ;; )
;; ;; function to open wttrin with first city on list
;; (defun bjm/wttrin ()
;;     "Open `wttrin' without prompting, using first city in `wttrin-default-cities'"
;;     (interactive)
;;     ;; save window arrangement to register
;;     (window-configuration-to-register :pre-wttrin)
;;     (delete-other-windows)
;;     ;; save frame setup
;;     (save-frame-config)
;;     (set-frame-width (selected-frame) 130)
;;     (set-frame-height (selected-frame) 48)
;;     ;; call wttrin
;;     (wttrin-query (car wttrin-default-cities))
;;     )
;; (advice-add 'wttrin :before #'bjm/wttrin-save-frame)


;; (defun bjm/wttrin-restore-frame ()
;;   "Restore frame and window configuration saved prior to launching wttrin."
;;   (interactive)
;;   (jump-to-frame-config-register)
;;   (jump-to-register :pre-wttrin)
  ;; )
;; (advice-add 'wttrin-exit :after #'bjm/wttrin-restore-frame)

;; PDF-Tools
;; o - outline
(with-eval-after-load 'pdf-tools
(define-key pdf-view-mode-map (kbd "C-c C-h") 'outline-hide-other)
;; (define-key pdf-view-mode-map (kbd "C-c C-a") 'outline-toggle-children)
  ;; (define-key pdf-view-mode-map (kbd "M-h") 'pdf-outline)
  ;; (define-key pdf-outline-minor-mode-map (kbd "i") 'pdf-outline)

  ;; (define-key pdf-outline-buffer-mode-map (kbd "M-h") 'outline-toggle-children)
  ;; (define-key outline-mode-map (kbd "a") 'outline-show-all)
  (message "nice")
  ;; (define-key pdf-outline-buffer-mode-map (kbd "M-o") 'outline-toggle-children)
)

;; LSP
(setq ccls-executable "/snap/bin/ccls")
(map!
 ;; :after lsp
 :leader
 :prefix "l"
 :desc "lsp-find-definition" "d" #'lsp-find-definition
 :desc "lsp-find-references" "r" #'lsp-find-references
 :desc "lsp-ui-imenu"        "i" #'lsp-ui-imenu
 :desc "lsp-rename"          "n" #'lsp-rename)
      ;; (:prefix "l")
      ;; 'lsp
  ;; (define-key lsp-mode-map (kbd "SPC")))

;; (defmacro hydra-move-macro ()
  ;; '(("h" evil-window-left "left")
  ;; ("l" evil-window-right "right")))

;; Window Navigation (faster using hydras)
;; (defhydra hydra-move (:body-pre (evil-window-left 1))
(defhydra hydra-move ()
  "Move"
  ("l" evil-window-right "right")
  ("h" evil-window-left  "left")
  ("k" evil-window-up    "up")
  ("j" evil-window-down  "down"))

(defun movement (dir)
  "Call the original movement direction then enter hydra-move"
  (cond ((string= dir "h") (evil-window-left 1))
        ((string= dir "l") (evil-window-right 1))
        ((string= dir "k") (evil-window-up 1))
        ((string= dir "j") (evil-window-down 1)))
  (hydra-move/body))

(define-key doom-leader-map (kbd "w h") (lambda () (interactive) (movement "h")))
(define-key doom-leader-map (kbd "w l") (lambda () (interactive) (movement "l")))
;; (define-key doom-leader-map (kbd "w h") 'hydra-move-left/body)
  ;; ("l" evil-window-right "right"))
