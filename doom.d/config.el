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

(setq doom-localleader-key ";")

;; ORG MODE
(add-hook! 'evil-org-mode-hook 'my/evil-org-mode-keybinds)

(defun my/evil-org-mode-keybinds ()
  (evil-define-key 'motion evil-org-mode-map
    (kbd "^") 'evil-org-beginning-of-line)
  (message "new evil org keybinds"))
;; (use-package! org
;;   :config
;; (map! :localleader
;;       :map org-mode-map

;;       ;;Motion
;;       "j" #'org-next-visible-heading
;;       "k" #'org-previous-visible-heading
;;       "J" #'org-forward-heading-same-level
;;       "K" #'org-backward-heading-same-level
;;       "u" #'outline-up-heading

;;       ;;Narrowing
;;       "n" nil ;; unmap default o mapping
;;       (:prefix ("n" . "narrow")
;;       :desc "subtree" "s" #'org-narrow-to-subtree
;;       :desc "widen"   "w" #'widen)

;;       ;; Sparse tree
;;       "s" :nil
;;       (:prefix ("s" . "sparse tree")
;;         :desc "regex" "r" #'org-regex
;;         :desc "todo" "t" #'org-tags-sparse-tree)
;;       "/" #'org-sparse-tree

;;       ;; Format
;;       "f" :nil
;;       (:prefix ("f" . "format")
;;         :desc "bullet" "b" #'org-cycle-list-bullet)

;;       ;; Linking
;;       "l" :nil
;;       (:prefix ("l" . "link")
;;         :desc "insert" "i" #'org-insert-link
;;         :desc "store" "s" #'org-store-link)

;;       ;; Insert
;;       :desc "insert-heading-respect-content" "h" #'org-insert-heading-respect-content
     
;;       "o" #'org-open-at-point
;;       ))

      ;; (:prefix ("d". "testing")
        ;; "t" #'org-toggle-checkbox))

(map! :leader
        "o" nil ;; unmap default o mapping
      (:prefix ("o" . "org")
        :desc "org-store-link" "l"  #'org-store-link
        :desc "org-agenda"     "a"  #'org-agenda
        :desc "org-capture"    "T"  #'org-capture))

;; TEXT MANIPULATION
(use-package! expand-region)
(with-eval-after-load 'expand-region
  (evil-global-set-key 'normal (kbd "J") #'er/contract-region)
  (evil-global-set-key 'visual (kbd "J") #'er/contract-region)
  (evil-global-set-key 'normal (kbd "K") #'er/expand-region)
  (evil-global-set-key 'visual (kbd "K") #'er/expand-region))

;; VTERM
(use-package vterm
  :load-path  "/home/edyer/Desktop/emacs-libvterm")

(require 'doom-modeline-core)
(require 'doom-modeline-segments)
(doom-modeline-def-modeline 'my-vterm-mode-line
  '(bar workspace-name window-number modals matches buffer-default-directory buffer-info remote-host buffer-position word-count parrot selection-info)
  '(objed-state misc-info persp-name battery grip irc mu4e gnus github debug lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs checker))

(add-hook! 'vterm-mode-hook (doom-modeline-set-modeline 'my-vterm-mode-line))

(with-eval-after-load 'vterm
  ;; (define-key vterm-mode-map (kbd "C-j") 'vterm-send-down)
  ;; (define-key vterm-mode-map (kbd "C-k") 'vterm-send-up)
  (evil-define-key '(normal insert) vterm-mode-map
    (kbd "M-k") 'vterm-send-up
    (kbd "M-j") 'vterm-send-down)

  ;; (setq frame-title-format '(:eval (if (buffer-file-name) (abbreviate-file-name (buffer-file-name)) "%b")))
  ;; (setq frame-title-format "NEATO")
  ;; (setq frame-title-format '("" "%b @ Emacs " emacs-version))
  ;; (doom-modeline-set-modeline 'my-vterm-mode-line)
  ;; (setq mode-line-format '("" "%b @ Emacs " default-directory))
  ;; (doom-modeline-set-project-modeline) ;; Display current working directory on modeline
  (message "vterm-new-keybindings"))

(defun show-current-working-dir-in-mode-line ()
  "Shows current working directory in the modeline."
  (interactive)
  (setq mode-line-format '("" default-directory))
  )

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


(use-package nov)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

(map! :leader
  ;; (:prefix "w"
    ;; :desc "Open vterm" "t"    #'vterm)
  (:prefix "f"
    :desc "find-file-in-known-projects" "f" #'projectile-find-file-in-known-projects
    :desc "counsel-find-file" "d" #'counsel-find-file)
   :desc "switch-to-buffer" "a" #'switch-to-buffer)

;; ATOMIC-CHROME
(use-package atomic-chrome)
(atomic-chrome-start-server)
(setq atomic-chrome-buffer-open-style 'window)

;; NAVIGATION

;; Evil Snipe
(require 'evil-snipe)
(evil-snipe-mode)
(evil-snipe-override-mode 1)
(setq evil-snipe-scope 'whole-visible)

(map! :leader
      (:desc "next buffer" "D" #'switch-to-next-buffer
        :desc "prev buffer" "d" #'switch-to-prev-buffer
        )
      (:prefix "s"
        :desc "swiper-isearch-thing-at-point" "s" #'swiper-isearch-thing-at-point)
      (:desc "repeat last command" "." #'repeat))

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

;; Modes

(map! :leader
      (:prefix ("F" . "format")
        :desc "auto-fill-mode" "a" #'auto-fill-mode
        :desc "fill-region" "r" #'fill-region))

;; DOXYGEN

;;###########################
;;#          MAGIT          #
;;###########################
;; (unmap! :leader
  ;; (:prefix "g"
    ;; ))
(map! :leader
      (:prefix "g"
        :desc "blame" "b" #'magit-blame
        :desc "log" "l" #'magit-log
        "L" nil ;; unmap default L mapping
        (:prefix ("L" . "log")
          :desc "file" "f" #'magit-log-buffer-file
          :desc "head" "h" #'magit-log-head
          :desc "log" "i" #'magit-log
          :desc "refresh" "r" #'magit-log-refresh-buffer)))

(define-suffix-command reset-upstream ()
  (interactive)
  (if (magit-confirm t (format "**WARNING** this will hard reset to upstream branch. Continue?"))
      (magit-run-git "reset" "--hard" "@{u}"))
  )
; fs
(define-suffix-command fixup-head ()
  "Make current commit a fixup to HEAD"
  (interactive)
  (magit-run-git "commit" "--fixup" "HEAD")
  )

(define-suffix-command reset-head-to-previous-commit ()
  "Soft reset head to the previous commit"
  (interactive)
  (magit-run-git "reset" "HEAD~")
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
                         '("u" "to upstream" reset-upstream))

 (transient-append-suffix 'magit-reset "w"
                         '("o" "previous-commit" reset-head-to-previous-commit))
 )

(with-eval-after-load 'evil
 (evil-define-key* '(normal visual) magit-mode-map
   "C-t" #'my/evil-scroll-down
   "C-v" #'my/evil-scroll-up)
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

;; Consistent Navigation
(define-key magit-mode-map [remap evil-scroll-down] 'my/evil-scroll-down)
(define-key magit-mode-map [remap evil-scroll-up]   'my/evil-scroll-up)

;;########
;; View ##
;;########

(use-package symbol-overlay)
(setf (cdr symbol-overlay-map) nil) ;; Remove default symbol-overlay-map (we don't want most of these bindings to clobber our evil bindings)
(define-key symbol-overlay-map (kbd "n") #'symbol-overlay-jump-next)
(define-key symbol-overlay-map (kbd "N") #'symbol-overlay-jump-prev)
(map! :leader
      (:prefix ("m" . "mark")
        :desc "mark symbol" "m" #'symbol-overlay-put
        :desc "mark single symbol" "M" #'symbol-overlay-put-one
        :desc "query-replace" "r" #'symbol-overlay-query-replace))
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

(use-package! pdf-tools
  :config
  (evil-define-key 'normal pdf-view-mode-map (kbd ":") 'pdf-view-goto-page)
  (map! :localleader
        :map pdf-view-mode-map

          "f" #'pdf-occur

          ;; History
          "c" #'pdf-history-clear
          "j" #'pdf-history-backward
          "k" #'pdf-history-forward

          "o" #'pdf-outline))

;; Outline Mode
;;
(map! :localleader
      :map outline-mode-map
      "c" #'outline-hide-entry
      "e" #'outline-show-entry
      "d" #'outline-hide-subtree
      "s" #'outline-show-subtree
      "l" #'outline-hide-leaves
      "k" #'outline-show-branches
      "i" #'outline-show-children
      "t" #'outline-hide-body
      "a" #'outline-show-all
      "q" #'outline-hide-sublevels
      "o" #'outline-hide-other)

;; LSP
(setq ccls-executable "/snap/bin/ccls")
(map!
 ;; :after lsp
 :leader
 :prefix "l"
 :desc "lsp-find-definition" "d" #'lsp-find-definition
 :desc "lsp-format"          "f" #'lsp-format-buffer
 :desc "lsp-find-references" "r" #'lsp-find-references
 :desc "lsp-ui-imenu"        "i" #'lsp-ui-imenu
 :desc "lsp-rename"          "n" #'lsp-rename
 :desc "find-related-file"   "o" #'ff-find-related-file
 :desc "find-related-file-other-window" "O" #'projectile-find-other-file-other-window)
      ;; (:prefix "l")
      ;; 'lsp
  ;; (define-key lsp-mode-map (kbd "SPC")))

;; (defmacro hydra-move-macro ()
  ;; '(("h" evil-window-left "left")
  ;; ("l" evil-window-right "right")))
;;###############
;; PROJECTILE ##
;;###############
(setq projectile-switch-project-action nil)
(map! :leader
      (:prefix "p"
        :desc "find-other-file" "o" #'projectile-find-other-file
        :desc "find-other-file-other-window" "O" #'projectile-find-other-file-other-window
      ))
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

;; (define-key doom-leader-map (kbd "w h") (lambda () (interactive) (movement "h")))
;; (define-key doom-leader-map (kbd "w l") (lambda () (interactive) (movement "l")))
(use-package windmove
  :ensure nil
  :bind
  (("C-M-h". windmove-left)
   ("C-M-l". windmove-right)
   ("C-M-k". windmove-up)
   ("C-M-j". windmove-down)))

;;#########################
;; FILE/FOLDER NAVIGATION #
;;#########################
;; Nothing here yet

;;###################
;; Compilation mode #
;;###################
(map! :leader
      (:prefix "c"
        :desc "ivy/compile"  "C"  #'compile
        :desc "my/ivy/compile"  "d"  #'my/ivy/compile
        :desc "recompile"  "c"  #'recompile
        :desc "kill compilation" "k" #'kill-compilation
        :desc "compilation set skip threshold" "t" #'compilation-set-skip-threshold))

;; (with-eval-after-load 'compilation
  ;; (setq compilation-auto-jump-to-first-error 1)
(setq compile-commands
      '("cd ~/kinetis && docker exec -it build_container /bin/bash -c \"cd /root/kinetis && make -f MakeIBST_kinetis \" && scp 1857-01X.axf edyer@pyrite:/home/bdi3000/edyer"
        "cd ~/kinetis && docker exec -it build_container /bin/bash -c \"cd /root/kinetis && make -f MakeIBST_kinetis -B > buildlog.txt\" && cat buildlog.txt && compiledb --parse buildlog.txt && scp 1857-01X.axf edyer@pyrite:/home/bdi3000/edyer"
        "cd ~/kinetis && docker exec -it build_container /bin/bash -c \"cd /root/kinetis && make -f Make213371 -B \" && scp 213371-01X.axf edyer@pyrite:/home/bdi3000/edyer"

        ;; Mx20Di
        "cd ~/release && compiledb make -f MakePldMx2XZn_Gen2 SW_PN=313365 SW_VER=02 SW_REV=X -j TOOLCHAIN=xilinx"
        "cd ~/release && compiledb make -f MakeGblMx2XZn_Gen2 SW_PN=313367 SW_VER=02 SW_REV=X -j TOOLCHAIN=xilinx"
        ;; "cd ~/general_atomics make -f MakeMcuXZnHDi_Gen2 SW_PN=313366 SW_VER=02 SW_REV=X -j TOOLCHAIN=xilinx"
        "neato"))
(defun my/ivy/compile ()
  (interactive)
  (ivy-read "compile-command: " compile-commands
            :action (lambda (x)
                      (compile x))))
  ;; (compile "cd ~/kinetis && docker exec -it build_container /bin/bash -c \"cd /root/kinetis && make -f MakeIBST_kinetis \""))

(setq helm-source-bookmarks '(~/kinetis))
