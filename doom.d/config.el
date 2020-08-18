(setq user-full-name "Reg Marr"

      user-mail-address "reginald.t.marr@gmail.com"

      doom-scratch-initial-major-mode 'lisp-interaction-mode
      ;;treemacs-width 32 ;;TODO
      doom-theme 'doom-material

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
;Org mode code capture
;
(setq my-major-mode-to-org-src
      '(("c++-mode" . "C++")
        ("python-mode" . "python")))

  (setq my-captured-snippet "")

(defun capture-code-snippet ()
  "Copy the current region and put it the org source code block."
  (interactive)
  (let ((code-snippet (buffer-substring-no-properties (mark) (point)))
        (func-name (which-function))
        (file-name (buffer-file-name))
        (line-number (line-number-at-pos (region-beginning)))
        (org-src-mode (cdr (assoc (format "%s" major-mode) my-major-mode-to-org-src))))
    (setq my-captured-snippet
          (format
          "file:%s::%s
          In ~%s~:
          #+BEGIN_SRC %s
          %s
          #+END_SRC"
          file-name
          line-number
          func-name
          org-src-mode
          code-snippet)))
   (org-capture nil "c"))
;; ------------------------------------------------------------
;;   Functions that help with capturing - from howardism
;; ------------------------------------------------------------

(require 'which-func)

(defun ha/org-capture-fileref-snippet (f type headers func-name)
  (let* ((code-snippet
          (buffer-substring-no-properties (mark) (- (point) 1)))
         (file-name   (buffer-file-name))
         (file-base   (file-name-nondirectory file-name))
         (line-number (line-number-at-pos (region-beginning)))
         (initial-txt (if (null func-name)
                          (format "From [[file:%s::%s][%s]]:"
                                  file-name line-number file-base)
                        (format "From ~%s~ (in [[file:%s::%s][%s]]):"
                                func-name file-name line-number
                                file-base))))
    (format "
   %s

   #+BEGIN_%s %s
%s
   #+END_%s" initial-txt type headers code-snippet type)))

(defun ha/org-capture-code-snippet (f)
  "Given a file, F, this captures the currently selected text
within an Org SRC block with a language based on the current mode
and a backlink to the function and the file."
  (with-current-buffer (find-buffer-visiting f)
    (let ((org-src-mode (replace-regexp-in-string "-mode" "" (format "%s" major-mode)))
          (func-name (which-function)))
      (ha/org-capture-fileref-snippet f "SRC" org-src-mode func-name))))

(defun ha/org-capture-clip-snippet (f)
  "Given a file, F, this captures the currently selected text
within an Org EXAMPLE block and a backlink to the file."
  (with-current-buffer (find-buffer-visiting f)
    (ha/org-capture-fileref-snippet f "EXAMPLE" "" nil)))

(defun ha/code-to-clock (&optional start end)
  "Send the currently selected code to the currently clocked-in org-mode task."
  (interactive)
  (org-capture nil "F"))

(defun ha/code-comment-to-clock (&optional start end)
  "Send the currently selected code (with comments) to the
currently clocked-in org-mode task."
  (interactive)
  (org-capture nil "f"))


;(add-to-list 'org-capture-templates
;            '("c" ;Key used to select this template
              ;template description
            ;"Code" 
              ;template type which is a node targeting an org file
             ; entry 
              ;template target
             ; (file "~/org/captured.org")
              ;The template for creating the capture item
             ; "* Code Snippet %U
             ; In ~%A~
             ; #+BEGIN_SRC %(major-mode)
             ; %i
             ; #+END_SRC
             ; %?"))
              ;; "* Code snippet %U\n%(format \"%s\" my-captured-snippet)"))
;; (setq org-capture-default-template "c")
;; (add-to-list 'org-capture-templates
;;               `("c" "Code Reference with Comments to Current Task"
;;                 "%(ha/org-capture-code-snippet \"%F\")\n\n   %?"))
;;                 ;:empty-lines 1))
;; (add-to-list 'org-capture-templates
;;               `("cl" "Link to Code Reference to Current Task"
;;                 "%(ha/org-capture-code-snippet \"%F\")"
;;                 :empty-lines 1 :immediate-finish t))

;; TEXT MANIPULATION
(use-package! expand-region)
(with-eval-after-load 'expand-region
  (evil-global-set-key 'normal (kbd "J") #'er/contract-region)
  (evil-global-set-key 'visual (kbd "J") #'er/contract-region)
  (evil-global-set-key 'normal (kbd "K") #'er/expand-region)
  (evil-global-set-key 'visual (kbd "K") #'er/expand-region))

;; VTERM
(use-package vterm
  :load-path "/home/rmarr/Downloads/gitDownloads/emacs-libvterm/")

;; (use-package "fzf" :init(setenv "FZF_DEFAULT_COMMAND" "--type file"))
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
    (kbd "M-j") 'vterm-send-down))

  ;; (setq frame-title-format '(:eval (if (buffer-file-name) (abbreviate-file-name (buffer-file-name)) "%b")))
  ;; (setq frame-title-format "NEATO")
  ;; (setq frame-title-format '("" "%b @ Emacs " emacs-version))
  ;; (doom-modeline-set-modeline 'my-vterm-mode-line)
  ;; (setq mode-line-format '("" "%b @ Emacs " default-directory))
  ;; (doom-modeline-set-project-modeline) ;; Display current working directory on modeline
  ;; (message "vterm-new-keybindings"))

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

(use-package symbol-overlay)

(use-package nov)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

;; (map! :leader
;;       (:prefix "c"
;;        :desc "dwim Comment" "Spc" #'comment-dwim))

(map! :leader
      (:desc "next buffer" "D" #'switch-to-next-buffer
        :desc "prev buffer" "d" #'switch-to-prev-buffer
        )
      ;; (:prefix "s"
      ;;   :desc "swiper-isearch-thing-at-point" "t" #'swiper-isearch-thing-at-point
      ;;   :desc "helm-projectile-rg" "p" #'helm-projectile-rg)
      (:desc "repeat last command" "." #'repeat))

(setq evil-scroll-count 5) ;; I like the scroll to be a bit more granular
(defun my/evil-scroll-down ()
  (interactive)
  (evil-scroll-down 10))

(defun my/evil-scroll-up ()
  (interactive)
  (evil-scroll-up 10))

;; AutComplete

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
;;
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
(setq ccls-executable "/home/rmarr/.local/bin/ccls")
(map!
 ;; :after lsp
 :leader
 :prefix "l"
 :desc "lsp-find-definition" "d" #'lsp-find-definition
 :desc "lsp-format"          "f" #'lsp-format-buffer
 :desc "lsp-find-references" "r" #'lsp-find-references
 :desc "lsp-ui-imenu"        "i" #'lsp-ui-imenu
 :desc "lsp-rename"          "n" #'lsp-rename

 ;;navigation
 :desc "next-func" "j" #'my/next-func
 :desc "prev-func" "k" #'my/prev-func

 :desc "find-related-file"   "o" #'ff-find-related-file
 :desc "find-related-file-other-window" "O" #'projectile-find-other-file-other-window)
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

;; (define-key doom-leader-map (kbd "w h") (lambda () (interactive) (movement "h")))
;; (define-key doom-leader-map (kbd "w l") (lambda () (interactive) (movement "l")))
;; (define-key doom-leader-map (kbd "w h") 'hydra-move-left/body)
  ;; ("l" evil-window-right "right"))
;; (use-package! fast-scroll
;; :config
;; (setq fast-scroll-throttle 0.5)
;; (add-hook 'fast-scroll-start-hook (lambda () (flycheck-mode -1)))
;; (add-hook 'fast-scroll-end-hook (lambda () (flycheck-mode 1)))
;; (fast-scroll-config)
;; (fast-scroll-mode 1)
;; )
;; (use-package! scrollkeeper)
;; (global-set-key [remap scroll-up-command] #'scrollkeeper-contents-up)
;; (global-set-key [remap scroll-down-command] #'scrollkeeper-contents-down)
;Custom remappings
;WANTED:
;remap M-; to Spc-c-SPC for comment dwim
;remap g-r from eval region to get references
;rempap Spc-s-b to Spc-G for search in project
;rempar Spc-g to search  in project
;also when searching don't include the ccls cache in results
;; Compilation mode
;;
(map! :leader
      (:prefix "c"
        :desc "ivy/compile"  "C"  #'compile
        :desc "my/ivy/compile"  "d"  #'my/ivy/compile
        :desc "recompile"  "c"  #'recompile
        :desc "kill compilation" "k" #'kill-compilation
        :desc "compilation set skip threshold" "t" #'compilation-set-skip-threshold))
;; (with-eval-after-load 'compilation
  (setq compilation-auto-jump-to-first-error 1)
(setq compile-commands
      '("docker exec -it funny_dhawan /bin/bash -c \"cd /shared/kinetis && make -f Make213371\" && scp /home/rmarr/kinetis/213371-01X.axf pyrite:/home/bdi3000/rmarr/"
        "docker exec -it funny_dhawan /bin/bash -c \"cd /shared/kinetis && make -f Make213371 -B\" && scp /home/rmarr/kinetis/213371-01X.axf pyrite:/home/bdi3000/rmarr/"
        "ssh blade && cd kinetis && make -f Make213371 -B"
        "cd ~/kinetis && docker exec -it agitated_borg /bin/bash -c \"cd /shared/kinetis && make -f Make213371 -Bwnk > buildlog.txt\" && cat buildlog.txt && compiledb --parse buildlog.txt"))
(defun my/ivy/compile ()
  (interactive)
  (ivy-read "compile-command: " compile-commands
            :action (lambda (x)
                      (compile x))))
;Puts the function name in the status bar
;Auto complete
(which-function-mode 1)
(smartparens-global-mode 1)
(require 'company)
(setq company-idle-delay 0.2
      company-minimum-prefix-length 3)
(add-hook 'after-init-hook 'global-company-mode)
;;LSP stuff but pertains to company-mode
(setq company-transformers nil company-lsp-async t company-lsp-cache-candidates nil)

;Org mode code capture
;
(with-eval-after-load 'org-mode
        (setq my-major-mode-to-org-src
        '(("c++-mode" . "C++")
                ("python-mode" . "python")))

        (setq my-captured-snippet "")

        (defun capture-code-snippet ()
        "Copy the current region and put it the org source code block."
        (interactive)
        (let ((code-snippet (buffer-substring-no-properties (mark) (point)))
                (func-name (which-function))
                (file-name (buffer-file-name))
                (line-number (line-number-at-pos (region-beginning)))
                (org-src-mode (cdr (assoc (format "%s" major-mode) my-major-mode-to-org-src))))
        (setq my-captured-snippet
                (format
                "file:%f::%f
                In ~%s~:
                #+BEGIN_SRC %s
                %a
                #+END_SRC"
                file-name
                line-number
                func-name
                org-src-mode
                code-snippet)))
        (org-capture nil "c"))

        (defun transform-square-brackets-to-round-ones(string-to-transform)
                "Transforms [ into ( and ] into ), other chars left unchanged."
                (concat
                (mapcar #'(lambda (c) (if (equal c ?[) ?\( (if (equal c ?]) ?\) c))) string-to-transform))
        )
        ;; Kill the frame if one was created for the capture
        (defvar kk/delete-frame-after-capture 0 "Whether to delete the last frame after the current capture")

        (defun kk/delete-frame-if-neccessary (&rest r)
                (cond
                        ((= kk/delete-frame-after-capture 0) nil)
                        ((> kk/delete-frame-after-capture 1)
                        (setq kk/delete-frame-after-capture (- kk/delete-frame-after-capture 1)))
                (t
                (setq kk/delete-frame-after-capture 0)
        (delete-frame))))

        (advice-add 'org-capture-finalize :after 'kk/delete-frame-if-neccessary)
        (advice-add 'org-capture-kill :after 'kk/delete-frame-if-neccessary)
        (advice-add 'org-capture-refile :after 'kk/delete-frame-if-neccessary)
)
;;new org templates
(defun org-capture-pdf-active-region ()
"Capture the active region of the pdf-view buffer."
        (let* ((pdf-buf-name (plist-get org-capture-plist :original-buffer))
                (pdf-buf (get-buffer pdf-buf-name)))
        (if (buffer-live-p pdf-buf)
                (with-current-buffer pdf-buf
                        (car (pdf-view-active-region-text)))
        (user-error "Buffer %S not alive." pdf-buf-name))))
(add-to-list 'org-capture-templates
        ;; '("c" ;Key used to select this template
        ;; ;template description
        ;; "Code"
        ;; ;template type which is a node targeting an org file
        ;; entry
        ;; ;template target
        ;; (file "~/org/captured.org")
        ;; ;The template for creating the capture item
        ;; "* Code snippet %U\n%(format \"%s\" my-captured-snippet)")
        ;; '("p"
        ;; "Protocol"
        ;; entry
        ;; (file+headline ,(concat org-directory "notes.org") "Inbox")
        ;; "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
        '("f"
        "Pdf Notes"
        entry
        (file "~/Notes.org")
        "* %?\n%(org-capture-pdf-active-region)\n")
        ;; '("L"
        ;; "Protocol Link"
        ;; entry
        ;; (file+headline ,(concat org-directory "notes.org") "Inbox")
        ;; "* %? [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n")
        )

;boilerplate is for plebs
(with-eval-after-load 'yasnippet
        (defun maybe_notify_snip (snip_str)
          "This function conditionally returns a string"
                (if (string= snip_str "0")
                     " "
                        (
concat (concat "\nstatic void " (concat snip_str "(int type, void *argPtr, int recordNum)"))
"\n{
        if (type == NOTIFY_GET) {
        }
        else (type == NOTIFY_SET) {
        }
}
")
                        )
                ))

;Fancy linking function defintions and implementations
    (require 'srefactor)
    (require 'srefactor-lisp)

    ;; OPTIONAL: ADD IT ONLY IF YOU USE C/C++.
    (semantic-mode 1) ;; -> this is optional for Lisp

    (define-key c-mode-map (kbd "M-RET") 'srefactor-refactor-at-point)
    (define-key c++-mode-map (kbd "M-RET") 'srefactor-refactor-at-point)
    (global-set-key (kbd "M-RET o") 'srefactor-lisp-one-line)
    (global-set-key (kbd "M-RET m") 'srefactor-lisp-format-sexp)
    (global-set-key (kbd "M-RET d") 'srefactor-lisp-format-defun)
    (global-set-key (kbd "M-RET b") 'srefactor-lisp-format-buffer)

;org jira
(setq jiralib-url "http://cesium/jira")

;eric says i need this
(after! company
  (setq company-idle-delay 0.01))

(use-package org-pdftools
  :hook (org-load . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :after org-noter
  :config
  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))
