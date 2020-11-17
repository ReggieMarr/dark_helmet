(setq comp-deferred-compilation t)

(map! :leader
      (:prefix ("e" . "emacs")
       :desc "reload-config" "r" #'my/reload-config
       :desc "open-config" "c" #'my/open-config)
      )

(defun my/reload-config ()
  (interactive)
  (load "~/dark_helmet/doom.d/config.el"))

(defun my/open-config ()
  (interactive)
  (find-file "~/dark_helmet/doom.d/config.org"))

(setq user-full-name "Eric Dyer"
      user-mail-address "dyereh@gmail.com")

(setq doom-localleader-key ";")

(setq doom-theme 'doom-monokai-classic ; Reminds me of Sublime-text & makes me feel at home
      display-line-numbers-type nil) ; Improve performance & disable line #'s by default
      ;; doom-font (font-spec :family "Emilbus Mono" :size 18)

(map! :leader
      "n" nil
      (:prefix ("n" . "narrow")
       :desc "page"    "p" #'narrow-to-page
       :desc "defun"   "d" #'narrow-to-defun
       :desc "region"  "r" #'narrow-to-region
       :desc "subtree" "s" #'narrow-to-subtree
       :desc "widen"   "w" #'widen
       ))

(setq doom-scratch-initial-major-mode 'lisp-interaction-mode)

(map! :leader
      "x" nil
      (:prefix ("x" . "dired")
       :desc "dired here" "d" #'(lambda () (interactive) (dired default-directory))
       :desc "dired" "D" #'dired
      ))

(setq delete-by-moving-to-trash t) ; Move to trash bin instead of permanently deleting it

(use-package dired
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    ;; "h" 'dired-single-up-directory
    ;; "l" 'dired-single-buffer)
    "h" 'dired-up-directory
    "l" 'dired-find-file)
  (setq dired-recursive-deletes "top"))

(use-package! notmuch
  :config
  (setq +notmuch-sync-backend 'mbsync)
  (setq message-kill-buffer-on-exit t) ;; Kills buffer after sending an email (otherwise sent message buffers would accumulate)
  )

(evil-global-set-key 'normal (kbd "C-j") #'universal-argument)

(map! :leader
      :desc "universal arg" "j" #'universal-argument
      :desc "universal 2arg" "k" #'(lambda () (interactive) (universal-argument) (universal-argument-more)))

(map! :map universal-argument-map
      :prefix doom-leader-key     "j" #'universal-argument-more
      :prefix doom-leader-alt-key "j" #'universal-argument-more)

;; (unmap! :leader
  ;; (:prefix "g"
    ;; ))
(use-package! magit
  :config
  (map! :leader
        (:prefix "g"
         :desc "blame" "b" #'magit-blame
         ;; :desc "status dwim" "g" #'magit-status
         :desc "status" "G" #'my/magit-status
         :desc "buffer-lock" "T" #'magit-toggle-buffer-lock

         ;; Git gutter
         :desc "next-hunk" "j" #'git-gutter:next-hunk
         :desc "prev-hunk" "k" #'git-gutter:previous-hunk
         :desc "popup-diff" "d" #'git-gutter:popup-diff
         :desc "file-statistics" "S" #'git-gutter:statistic

         "s" nil
         (:prefix ("s" . "status")
          :desc "find"       "s" #'my/magit-status
          :desc "cfgdb"      "c" #'(lambda () (interactive) (magit-status "~/cfgdb"))
          :desc "kinetis"    "k" #'(lambda () (interactive) (magit-status "~/kinetis"))
          :desc "release"    "r" #'(lambda () (interactive) (magit-status "~/release"))
          :desc "ga"         "g" #'(lambda () (interactive) (magit-status "~/general-atomics"))
          :desc "ga/release" "R" #'(lambda () (interactive) (magit-status "~/general-atomics/release")))

         ;; Log
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
        (magit-run-git "reset" "--hard" "@{u}")))

  (define-suffix-command fixup-head ()
  "Make current commit a fixup to HEAD"
  (interactive)
  (magit-run-git "commit" "--fixup" "HEAD"))

  (define-suffix-command reset-head-to-previous-commit ()
    "Soft reset head to the previous commit"
    (interactive)
    (magit-run-git "reset" "HEAD~"))

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
  (with-eval-after-load 'magit
 (evil-define-key* '(normal visual) magit-mode-map
   "C-t" #'my/evil-scroll-down
   "C-v" #'my/evil-scroll-up)
))

;; Automatically refresh status buffer
(add-hook 'after-save-hook 'magit-after-save-refresh-status t)

;; Prevent long refnames from hiding commit messages in the log
(setq magit-log-show-refname-after-summary t)
(setq magit-log-margin '(t age-abbreviated 15 t 10))

(defun my/magit-status ()
  "Use ivy to specify directory from which to open a magit status buffer.
Default starting place is the home directory."
  (interactive)
  (let ((default-directory "~/"))
    (ivy-read "git status: " #'read-file-name-internal
              :matcher #'counsel--find-file-matcher
              :action #'(lambda (x)
                          (magit-status x))
              :preselect (counsel--preselect-file)
              :require-match 'confirm-after-completion
              :history 'file-name-history
              :keymap counsel-find-file-map
              :caller 'my/magit-status)))

(defun my/magit-status-2 ()
  (interactive)
  (execute-extended-command 16 "magit-status"))
  ;; (counsel--find-file-1 "Git status: " "" #'magit-status 'my/magit-status)
  ;; (ivy-read  "my prompt: " (directory-files "~")
  ;;            :action #'(lambda (x)
  ;;                        (magit-status x))))
;; (lambda (x)
;;   "Return the hyperbolic cosine of X."
;;   (* 0.5 (+ (exp x) (exp (- x)))))
;; List of repositories
(setq magit-repository-directories
      `(("~" . 1)))
;;       `(("~/release"      . 1)
;;         ("~/kinetis"      . 1)
;;         ("~/dark_helmet"  . 1)))
        ;; ("~/dark_helment" . DEPTH3)))

;; (setq magit-repolist-columns
;;       '(("Name"    25 magit-repolist-column-ident                  ())
;;         ("Version" 25 magit-repolist-column-version                ())
;;         ("D"        1 magit-repolist-column-dirty                  ())
;;         ("L<U"      3 magit-repolist-column-unpulled-from-upstream ((:right-align t)))
;;         ("L>U"      3 magit-repolist-column-unpushed-to-upstream   ((:right-align t)))
;;         ("Path"    99 magit-repolist-column-path                   ())))

;; ;; Consistent Navigation
;; ;; (define-key magit-mode-map [remap evil-scroll-down] 'my/evil-scroll-down)
;; ;; (define-key magit-mode-map [remap evil-scroll-up]   'my/evil-scroll-up)

(defun my/open-buffer-path-in-explorer ()
  "Run explorer on the directory of the current buffer."
  (interactive)
  (shell-command (concat
                  "xdg-open "
                  default-directory)))

(map! :leader
      (:prefix "w"
       :desc "open in explorer" "x"  #'my/open-buffer-path-in-explorer))

(require 'notmuch)

(use-package! ivy
 :config
 (map! :leader
     "A" #'ivy-switch-buffer))

(add-hook! 'evil-org-mode-hook 'my/evil-org-mode-keybinds)

(defun my/evil-org-mode-keybinds ()
  (evil-define-key 'motion evil-org-mode-map
    (kbd "^") 'evil-org-beginning-of-line)
  (setq ispell-local-dictionary "en_US")
  (message "new evil org keybinds"))

(use-package! org
  :config

  (map! :leader
        "a" nil
        (:prefix ("a" . "switch buffer")
         :desc "org" "o" #'org-switchb))

 (evil-define-key* '(normal visual insert) org-mode-map
   (kbd "C-j") #'org-forward-element
   (kbd "C-k") #'org-backward-element)

  (map! :localleader
        :map org-mode-map

        ;;Motion
        ;; "j" #'org-next-visible-heading
        "j" #'org-down-element
        "k" #'org-previous-visible-heading
        "u" #'outline-up-heading

        ";" #'org-edit-special
        
        ;;Narrowing
        "n" nil ;; unmap default o mapping
        (:prefix ("n" . "narrow")
         :desc "subtree" "s" #'org-narrow-to-subtree
         :desc "block" "b" #'org-narrow-to-block
         :desc "widen"   "w" #'widen)

        ;; Sparse tree
        "s" :nil
        (:prefix ("s" . "sparse tree")
         :desc "regex" "r" #'org-regex
         :desc "todo" "t" #'org-tags-sparse-tree)
        "/" #'org-sparse-tree

        ;; Format
        "f" :nil
        (:prefix ("f" . "format")
         :desc "bullet" "b" #'org-cycle-list-bullet
         :desc "table"  "t" #'org-table-create-or-convert-from-region)

        ;; Linking
        "l" :nil
        (:prefix ("l" . "link")
         :desc "insert" "i" #'org-insert-link
         :desc "store" "s" #'org-store-link)

        "i" :nil
        (:prefix ("i" . "insert")
         :desc "link" "l" #'org-insert-link
         :desc "item" "i" #'org-insert-item
         :desc "todo heading" "t" #'org-insert-todo-heading
         :desc "insert-heading" "h" #'org-insert-heading
         :desc "insert-heading-respect-content" "H" #'org-insert-heading-respect-content)

        "t" :nil
        (:prefix ("t" . "toggle")
         :desc "heading" "h" #'org-toggle-heading
         :desc "item" "i" #'org-toggle-item)


        "m" :nil
        (:prefix ("r" . "refile")
         :desc "refile" "r" #'org-refile)
        ;; insert
        "o" #'org-open-at-point
        )

  ;; Open org-edit-special in current window
  (setq org-src-window-setup 'current-window)
  )

      ;; (:prefix ("d". "testing")
        ;; "t" #'org-toggle-checkbox))

(map! :leader
      "o" nil ;; unmap default o mapping
      (:prefix ("o" . "org")
       :desc "org-store-link" "l"  #'org-store-link
       :desc "org-agenda"     "a"  #'org-agenda
       :desc "org-capture"    "c"  #'org-capture))

;; (add-hook! 'org-mode-hook
;; (set-face-attribute 'org-block-begin-line nil :height 0.7 :slant 'normal)
;; (set-face-attribute 'org-block-end-line nil :height 0.7 :slant 'normal))

(use-package! org
  :config
  (require 'color)
  (custom-set-faces! `(org-block :background
                                 ,(color-darken-name
                                   (face-attribute 'default :background) 2))))
;;   (custom-set-faces! `(org-block :background ,(doom-darken 'bg 0.4))))
;;https://github.com/hlissner/emacs-doom-themes/blob/master/themes/doom-one-theme.el#L36
;; (custom-set-faces! '(org-block :background "#FF0000"))

(use-package! org
  :config

  (map! :localleader
        ;; :map org-mode-map

        ;; ;;Motion
        ;; "j" #'org-next-visible-heading
        ;; "k" #'org-previous-visible-heading
        ;; "J" #'org-forward-heading-same-level
  ))

(use-package! org-jira
  :init
  (if (file-directory-p "~/.org-jira") () (make-directory "~/.org-jira"))

  :config
  (setq jiralib-url "http://cesium:8080/jira"))

(use-package! org
  :init
  (setq org-export-creator-string "Eric Dyer"
        org-odt-preferred-output-format "docx"
        org-export-default-language "en"
        org-export-preserve-breaks t
        org-export-headline-levels 3
        org-export-with-toc 3
        )
  )

;; (with-eval-after-load 'pdf-tools
;; (define-key pdf-view-mode-map (kbd "C-c C-h") 'outline-hide-other)
;; ;; (define-key pdf-view-mode-map (kbd "C-c C-a") 'outline-toggle-children)
;;   ;; (define-key pdf-view-mode-map (kbd "M-h") 'pdf-outline)
;;   ;; (define-key pdf-outline-minor-mode-map (kbd "i") 'pdf-outline)

;;   ;; (define-key pdf-outline-buffer-mode-map (kbd "M-h") 'outline-toggle-children)
;;   ;; (define-key outline-mode-map (kbd "a") 'outline-show-all)
;;   ;; (message "nice")
;;   ;; (define-key pdf-outline-buffer-mode-map (kbd "M-o") 'outline-toggle-children)
;; )

;; (use-package! pdf-tools
;;   :config
;;   (evil-define-key 'normal pdf-view-mode-map (kbd ":") 'pdf-view-goto-page)
;;   (map! :localleader
;;         :map pdf-view-mode-map
;;           "f" #'pdf-occur
;;           ;; History
;;           "c" #'pdf-history-clear
;;           "j" #'pdf-history-backward
;;           "k" #'pdf-history-forward

;;           "o" #'pdf-outline))

;; (setq pdf-view-display-size 'fit-width)
;; (with-eval-after-load 'pdf-view
;;   (require 'pdf-continuous-scroll-mode))
;; (add-hook 'pdf-view-mode-hook 'pdf-continuous-scroll-mode)

;; Add directory of personal snippets to path
(use-package! yasnippet
  :config
  ;; (setq yas-snippet-dirs '("~/dark_helmet/snippets"))
  (setq yas-snippet-dirs (append yas-snippet-dirs
                                 '("~/dark_helmet/snippets")))
  ;; (yas-reload-all)
  (map! :map evil-motion-state-map )
  (map! :map yas-minor-mode-map
        "C-y" #'yas-expand)
        ;; "C-y" #'company-yasnippet)

  (dolist (map '(evil-motion-state-map
                 evil-insert-state-map
                 evil-emacs-state-map))
    (define-key (eval map) "\C-y" nil))
  (setq yas-fallback-behavior '(apply tab-jump-out 1))
  )

  ;; (defun check-expansion ()
  ;;   (save-excursion
  ;;     (if (looking-at "\\_>") t
  ;;       (backward-char 1)
  ;;       (if (looking-at "\\.") t
  ;;         (backward-char 1)
  ;;         (if (looking-at "->") t nil)))))

  ;; (defun do-yas-expand ()
  ;;   (let ((yas/fallback-behavior 'return-nil))
  ;;     (yas/expand)))

  ;; (defun tab-indent-or-complete ()
  ;;   (interactive)
  ;;   (if (minibufferp)
  ;;       (minibuffer-complete)
  ;;     (if (or (not yas/minor-mode)
  ;;             (null (do-yas-expand)))
  ;;         (if (check-expansion)
  ;;             (company-complete-common)
  ;;           (indent-for-tab-command)))))

  ;; (global-set-key [tab] 'tab-indent-or-complete)

;; (defvar company-mode/enable-yas t
;;   "Enable yasnippet for all backends.")

;; (defun company-mode/backend-with-yas (backend)
;;   (if (and (listp backend) (member 'company-yasnippet backend))
;;       backend
;;     (append (if (consp backend) backend (list backend))
;;             '(:with company-yasnippet))))
;; (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))

  ;; (map! :localleader
  ;;       :map org-mode-map

  ;;       (:prefix ("s" . "snippet")
  ;;        :desc "subtree" "s" #'org-narrow-to-subtree
  ;;        :desc "widen"   "w" #'widen))

(use-package! vterm
  :commands vterm vterm-mode
  ;; :hook (vterm-mode . doom-mark-buffer-as-real-h)
  :init
  ;; Add current path to Vterm modeline
  (require 'doom-modeline-core)
  (require 'doom-modeline-segments)
  (doom-modeline-def-modeline 'my-vterm-mode-line
    '(bar workspace-name window-number modals matches buffer-default-directory buffer-info remote-host buffer-position word-count parrot selection-info)
    '(objed-state misc-info persp-name battery grip irc mu4e gnus github debug lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs checker))
  (add-hook! 'vterm-mode-hook (doom-modeline-set-modeline 'my-vterm-mode-line))

  (evil-define-key '(normal insert) vterm-mode-map
    (kbd "M-k") 'vterm-send-up
    (kbd "M-j") 'vterm-send-down)

  :config
  ;; Once vterm is dead, the vterm buffer is useless. Why keep it around? We can
  ;; spawn another if want one.
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-max-scrollback 5000)
  (setq confirm-kill-processes nil)
  (setq-hook! 'vterm-mode-hook
    ;; Don't prompt about dying processes when killing vterm
    confirm-kill-processes nil
    ;; Prevent premature horizontal scrolling
    hscroll-margin 0)
  ;; Restore the point's location when leaving and re-entering insert mode.
  ;; (add-hook! 'vterm-mode-hook
  ;;   (defun +vterm-init-remember-point-h ()
  ;;     (add-hook 'evil-insert-state-exit-hook #'+vterm-remember-insert-point-h nil t)
  ;;     (add-hook 'evil-insert-state-entry-hook #'+vterm-goto-insert-point-h nil t)))
)

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

;; Add directory & descendant directories to load path
;; (let ((default-directory "~/dark_helmet/privatePlugins"))
;; (normal-top-level-add-subdirs-to-load-path))

;; (use-package xwwp-full
;;   :load-path "~/.emacs.d/xwwp"
;;   :custom
;;   (xwwp-follow-link-completion-system 'helm)
;;   :bind (:map xwidget-webkit-mode-map
;;               ("v" . xwwp-follow-link)
;;               ("t" . xwwp-ace-toggle)))

(map! :leader
      "a" nil)

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (pos) 'read-face-name)
                  (get-char-property (pos) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

;; (add-hook! 'org-capture-mode-hook)
;; ;; ORG Capture
;;   (add-to-list 'org-capture-templates
;;         ;; '(("t" "Todo" entry (file+headline (concat org-directory "inbox.org") "Tasks")
;;           ;; "* TODO %?\n  %U\n  %i\n  %a")
;;         '("c" "Code Snippet" entry
;;          ;; (file (concat org-directory "/snippets.org"))
;;          (file "~/org/snippets.org")
;;          ;; Prompt for tag and language
;;          "* %A \n#+BEGIN_SRC c\n%i#+END_SRC"))
;;          ("m" "Media" entry
;;           (file+datetree (concat org-directory "media.org"))
;;           "* %?\nURL: \nEntered on %U\n")))

(defun org-hide-src-block-delimiters()
  (interactive)
  (save-excursion (goto-char (point-max))
      (while (re-search-backward "#\\+BEGIN_SRC\\|#\\+END_SRC" nil t)
         (let ((ov (make-overlay (line-beginning-position)
             (1+ (line-end-position)))))
         (overlay-put ov 'invisible t)))))


;; TEXT MANIPULATION
(use-package! expand-region
  :init )
(with-eval-after-load 'expand-region
  (evil-global-set-key 'normal (kbd "J") #'er/contract-region)
  (evil-global-set-key 'visual (kbd "J") #'er/contract-region)
  (evil-global-set-key 'normal (kbd "K") #'er/expand-region)
  (evil-global-set-key 'visual (kbd "K") #'er/expand-region))

(use-package! company
  :config
  (setq company-idle-delay 0.01
        company-minimum-prefix-length 1))

(add-hook! 'c-mode-hook
  (setq which-function-mode t))
  ;; (setq which-func-mode t))

  ;; (setq frame-title-format '(:eval (if (buffer-file-name) (abbreviate-file-name (buffer-file-name)) "%b")))
  ;; (setq frame-title-format "NEATO")
  ;; (setq frame-title-format '("" "%b @ Emacs " emacs-version))
  ;; (doom-modeline-set-modeline 'my-vterm-mode-line)
  ;; (setq mode-line-format '("" "%b @ Emacs " default-directory))
  ;; (doom-modeline-set-project-modeline) ;; Display current working directory on modeline
  ;; (message "vterm-new-keybindings"))



;; (use-package nov)
;; (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

(map! :leader
  ;; (:prefix "w"
    ;; :desc "Open vterm" "t"    #'vterm)
  (:prefix "f"
    ;; :desc "find-file-in-known-projects" "f" #'projectile-find-file-in-known-projects
    :desc "counsel-find-file" "d" #'counsel-find-file)
   :desc "switch-to-buffer" "a" #'switch-to-buffer)

;; ATOMIC-CHROME
;; (use-package atomic-chrome)
;; (atomic-chrome-start-server)
;; (setq atomic-chrome-buffer-open-style 'window)

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
        :desc "swiper-isearch-thing-at-point" "t" #'swiper-isearch-thing-at-point)
        ;; :desc "helm-projectile-rg" "p" #'helm-projectile-rg)
      (:desc "repeat last command" "." #'repeat))

;; I like the scroll to be a bit more granular
(setq-default evil-scroll-count 10)
;;(add-hook 'evil-local-mode-hook (setq evil-scroll-count 5) (message "noice %d" evil-scroll-count))
;; (add-hook 'evil-local-mode-hook (message "noice"))
;; (defun my/evil-scroll-down ()
;;   (interactive)
;;   (evil-scroll-down 10))

;; (defun my/evil-scroll-up ()
;;   (interactive)
;;   (evil-scroll-up 10))

(define-key evil-normal-state-map (kbd "M-d") #'my/evil-scroll-down)
(define-key evil-normal-state-map (kbd "M-u") #'my/evil-scroll-up)

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

;; ;;########
;; ;; View ##
;; ;;########
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package! symbol-overlay
  :config
  (setf (cdr symbol-overlay-map) nil) ;; Remove default symbol-overlay-map (we don't want most of these bindings to clobber our evil bindings)
  (define-key symbol-overlay-map (kbd "n") #'symbol-overlay-jump-next)
  (define-key symbol-overlay-map (kbd "N") #'symbol-overlay-jump-prev)
  (map! :leader
        (:prefix ("m" . "mark")
         :desc "mark symbol" "m" #'symbol-overlay-put
         :desc "mark single symbol" "M" #'symbol-overlay-put-one
         :desc "query-replace" "r" #'symbol-overlay-query-replace
         :desc "remove-all" "R" #'symbol-overlay-remove-all)))
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
;; (setq ccls-executable "/snap/bin/ccls")
(setq lsp-clients-clangd-args '("-j=3"
                                "--background-index"
                                "--clang-tidy"
                                "--completion-style=detailed"
                                "--header-insertion=never"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))
(map!
 ;; :after lsp
 :leader
 :prefix "l"
 :desc "lsp-find-definition" "d" #'lsp-find-definition
 :desc "lsp-format"          "f" #'lsp-format-buffer
 :desc "lsp-find-references" "r" #'lsp-find-references
 :desc "lsp-ui-imenu"        "i" #'lsp-ui-imenu
 :desc "peek definition"     "l" #'lsp-ui-peek-find-definitions
 :desc "peek definition"     "s" #'lsp-ui-peek-find-references
 :desc "lsp-rename"          "n" #'lsp-rename

 ;;navigation
 :desc "next-func" "j" #'my/next-func
 :desc "prev-func" "k" #'my/prev-func

 :desc "find-related-file"   "o" #'ff-find-related-file
 :desc "find-related-file-other-window" "O" #'projectile-find-other-file-other-window)

(setq lsp-ui-peek-enable t)
(setq lsp-ui-peek-always-show t) ;; Show peek view even if only 1 cross reference
(setq lsp-ui-peek-show-directory nil)

(defun my-c-mode-keymap ()
  (map! :localleader
        :map c-mode-base-map

        (:prefix ("c" . "code")
         :desc "clang format diff" "f" #'my/clang-format-diff)))

(add-hook 'c-initialization-hook 'my-c-mode-keymap)

(defun my/clang-format-diff ()
  (interactive)
  (shell-command (concat "cd " (projectile-project-root) " && git diff -U0 --no-color HEAD | clang-format-diff.py -p1 -i -v"))
  (revert-buffer :ignore-auto :noconfirm)
  )
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

(defun my/next-func ()
  (interactive)
  (c-beginning-of-defun -1)
  (reposition-window))


(defun my/prev-func ()
  (interactive)
  (c-beginning-of-defun)
  (reposition-window))

;; (define-key doom-leader-map (kbd "w h") (lambda () (interactive) (movement "h")))
;; (define-key doom-leader-map (kbd "w l") (lambda () (interactive) (movement "l")))
;; (use-package windmove
;;   :ensure nil
;;   :bind
;;   (("C-M-h". windmove-left)
;;    ("C-M-l". windmove-right)
;;    ("C-M-k". windmove-up)
;;    ("C-M-j". windmove-down)))

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
        :desc "compilation set skip threshold" "t" #'compilation-set-skip-threshold)
      (:prefix "w"
       :desc "compilation" "c" #'(lambda () (interactive) (my/switch-to-buffer "*compilation*"))))

;; (with-eval-after-load 'compilation
  ;; (setq compilation-auto-jump-to-first-error 1)


(defun my/switch-to-buffer (termName)
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

(setq compile-commands
      '("cd ~/kinetis && docker exec -u root -it build_container /bin/bash -c \"cd $HOME/kinetis && make -f MakeIBST_kinetis \" && scp 1857-01X.axf edyer@pyrite:/home/bdi3000/edyer"
        "cd ~/kinetis && docker exec -u root -it build_container /bin/bash -c \"cd $HOME/kinetis && make -f MakeIBST_kinetis -B > buildlog.txt\" && cat buildlog.txt && compiledb --parse buildlog.txt && scp 1857-01X.axf edyer@pyrite:/home/bdi3000/edyer"
        "cd ~/kinetis && docker exec -u root -it build_container /bin/bash -c \"cd $HOME/kinetis && make -f Make213371 -B \" && scp 213371-01X.axf edyer@pyrite:/home/bdi3000/edyer"
        "cd ~/kinetis && docker exec -u root -it build_container /bin/bash -c \"cd $HOME/kinetis && make -f Make213371 \" && scp 213371-01X.axf edyer@pyrite:/home/bdi3000/edyer"

        ;; IBST
        "cd ~/kinetis && docker exec -u root -it build_container /bin/bash -c \"cd $HOME/kinetis && make -f Make231857 \" && scp 231857-01X.axf edyer@pyrite:/home/bdi3000/edyer"
        "cd ~/kinetis && docker exec -u root -it build_container /bin/bash -c \"cd $HOME/kinetis && make -f Make231857 -B > buildlog.txt\" && cat buildlog.txt && compiledb --parse buildlog.txt && scp 231857-01X.axf edyer@pyrite:/home/bdi3000/edyer"

        "cd ~/kinetis && make -f MakeIBST_linux"
        "cd ~/kinetis && compiledb -n make -B -f MakeIBST_linux"
        "cd ~/kinetis/projects/UnifiedLensArch && make -f MakeDemo_Linux example=posix"

        ;; TASYS
        "cd ~/tasys && make -f MakeMcuTasys MAKE_SUBMODULE=mx/MakeMcuMx10Zn SW_PN=76981 SW_VER=03 SW_REV=X -j TOOLCHAIN=xilinx"
        "cd ~/tasys && make -f MakeMcuTasys MAKE_SUBMODULE=mx/MakeMcuMx10Zn SW_PN=76981 SW_VER=03 SW_REV=X -j TOOLCHAIN=xilinx -B"

        ;; Mx20Di
        "cd ~/release && compiledb make -f MakePldMx2XZn_Gen2 SW_PN=313365 SW_VER=02 SW_REV=X -j TOOLCHAIN=xilinx"
        "cd ~/release && compiledb make -f MakeGblMx2XZn_Gen2 SW_PN=313367 SW_VER=02 SW_REV=X -j TOOLCHAIN=xilinx"

        ;; Octave
        "cd ~/tasys/TLE_Matlab && octave matlab_srd_implementation.m"
        ;; "cd ~/general_atomics make -f MakeMcuXZnHDi_Gen2 SW_PN=313366 SW_VER=02 SW_REV=X -j TOOLCHAIN=xilinx"
        "cd ~/kinetis/projects/UnifiedLensArch/drivers/motorDrivers && gcc -o motorStub testMotorDriverStub.c motorDriverStub.c && ./motorStub"

        "neato"))
(defun my/ivy/compile ()
  (interactive)
  (ivy-read "compile-command: " compile-commands
            :action (lambda (x)
                      (compile x))))
  ;; (compile "cd ~/kinetis && docker exec -it build_container /bin/bash -c \"cd /root/kinetis && make -f MakeIBST_kinetis \""))

(setq helm-source-bookmarks '(~/kinetis))

;; Bootstrap Quelpa
(unless (package-installed-p 'quelpa)
  (with-temp-buffer
    (url-insert-file-contents "https://raw.githubusercontent.com/quelpa/quelpa/master/quelpa.el")
    (eval-buffer)
    (quelpa-self-upgrade)))

;; TODO figure out why this makes emacs mad
;; (quelpa
;;  '(quelpa-use-package
;;    :fetcher git
;;    :url "https://github.com/quelpa/quelpa-use-package.git"))
;; (require 'quelpa-use-package)

;; (use-package matrix-client
;;   :quelpa (matrix-client :fetcher github :repo "alphapapa/matrix-client.el"
;;                          :files (:defaults "logo.png" "matrix-client-standalone.el.sh")))

;; (require 'flx-ido)
;; (ido-mode 1)
;; (ido-everywhere 1)
;; (flx-ido-mode 1)
;; disable ido faces to see flx highlights.
;; (setq ido-enable-flex-matching t)
;; (setq ido-use-faces nil)

(use-package telega
  :load-path  "~/telega.el"
  :commands (telega)
  :defer t)

;; (defun eide-smart-tab-jump-out-or-indent (&optional arg)
;;   "Smart tab behavior. Jump out quote or brackets, or indent."
;;   (interactive "P")
;;   (if (-contains? (list "\"" "'" ")" "}" ";" "|" ">" "]" ) (make-string 1 (char-after)))
;;       (forward-char 1)
;;     (indent-for-tab-command arg)))

;; (global-set-key [remap indent-for-tab-command]
;;                 'eide-smart-tab-jump-out-or-indent)
