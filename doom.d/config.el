(setq user-full-name "Reg Marr"

      user-mail-address "reginald.t.marr@gmail.com"

      doom-scratch-initial-major-mode 'lisp-interaction-mode
      ;;treemacs-width 32 ;;TODO
      doom-theme 'doom-spacegrey

      ;; Improve performance & disable line #'s by defausdlt
      display-line-numbers-type nil

)
(add-to-list 'custom-theme-load-path "~/Downloads/gitDownloads/solo-jazz-emacs-theme/")
(require 'package)


(package-initialize)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
;(setq use-package-always-ensure t) ;;Globally ensure that a package will be automatically installed

(setq doom-localleader-key ";")

;; ORG MODE
(add-hook! 'evil-org-mode-hook 'my/evil-org-mode-keybinds)

(defun my/evil-org-mode-keybinds ()
  (evil-define-key 'motion evil-org-mode-map
    (kbd "^") 'evil-org-beginning-of-line)
  (message "new evil org keybinds"))

(map! :leader
        "o" nil ;; unmap default o mapping
      (:prefix ("o" . "org")
        :desc "org-store-link" "l"  #'org-store-link
        :desc "org-agenda"     "a"  #'org-agenda
        :desc "org-capture"    "T"  #'org-capture))
;Org mode code capture
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

(require 'doom-modeline-core)
(require 'doom-modeline-segments)
(doom-modeline-def-modeline 'my-vterm-mode-line
  '(bar workspace-name window-number modals matches buffer-default-directory buffer-info remote-host buffer-position word-count parrot selection-info)
  '(objed-state misc-info persp-name battery grip irc mu4e gnus github debug lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs checker))

(add-hook! 'vterm-mode-hook (doom-modeline-set-modeline 'my-vterm-mode-line))

;; (with-eval-after-load 'vterm
  ;; (evil-define-key '(normal insert) vterm-mode-map
  ;;   (kbd "M-k") 'vterm-send-up
  ;;   (kbd "M-j") 'vterm-send-down))
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
  (open-named-terminal "std-term")
  (emojify-mode))

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
(setq ccls-executable "/usr/bin/ccls")
(setq ccls-initialization-options '(:index (:comments 2) :completion (:detailedLabel t)))
(setq ccls-sem-highlight-method 'font-lock)
;; alternatively, (setq ccls-sem-highlight-method 'overlay)

;; For rainbow semantic highlighting
;;(ccls-use-default-rainbow-sem-highlight)
(defun ccls/callee () (interactive) (lsp-ui-peek-find-custom "$ccls/call" '(:callee t)))
(defun ccls/caller () (interactive) (lsp-ui-peek-find-custom "$ccls/call"))
(defun ccls/vars (kind) (lsp-ui-peek-find-custom "$ccls/vars" `(:kind ,kind)))
(defun ccls/base (levels) (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels)))
(defun ccls/derived (levels) (lsp-ui-peek-find-custom "$ccls/inheritance" `(:levels ,levels :derived t)))
(defun ccls/member (kind) (interactive) (lsp-ui-peek-find-custom "$ccls/member" `(:kind ,kind)))

;; References w/ Role::Role
(defun ccls/references-read () (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
    (plist-put (lsp--text-document-position-params) :role 8)))

;; References w/ Role::Write
(defun ccls/references-write ()
  (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
   (plist-put (lsp--text-document-position-params) :role 16)))

;; References w/ Role::Dynamic bit (macro expansions)
(defun ccls/references-macro () (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
   (plist-put (lsp--text-document-position-params) :role 64)))

;; References w/o Role::Call bit (e.g. where functions are taken addresses)
(defun ccls/references-not-call () (interactive)
  (lsp-ui-peek-find-custom "textDocument/references"
   (plist-put (lsp--text-document-position-params) :excludeRole 32)))
;lsp mapping
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
        '("docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make231857 SW_REV=- -j -B\" && scp /home/reggiemarr/kinetis/231857-01-.axf rmarr@pyrite:/home/bdi3000/rmarr/"
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make231857 SW_REV=X -j -B\" && scp /home/reggiemarr/kinetis/231857-01X.axf rmarr@pyrite:/home/bdi3000/rmarr/"
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make231857 SW_REV=Y -j -B\""
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make231857 SW_REV=X -j -B\""
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make217750 SW_REV=Y -j -B\""
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make231857 SW_REV=X -j -B\" | compiledb"
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make231857 SW_REV=Y -j -B\" | compiledb"
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f MakeLibraryModule SW_REV=X -j -B\""
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f MakeTowerK60F SW_REV=X -j -B\""
                "docker exec -it bob /bin/bash -c \"cd /shared/kinetis && make -f Make75177 SW_REV=Y -j -B\" && scp /home/reggiemarr/kinetis/231857-01X.axf rmarr@pyrite:/home/bdi3000/rmarr/"
                "docker exec -it bob /bin/bash -c \"cd /shared/release && make.py 77619-01X\""
                "docker exec -i bob /bin/bash -c \"cd /shared/release && make.py 76617-02X -B | compiledb\""
                "docker exec -it bob /bin/bash -c \"cd /shared/release && make.py 227269-01X -B\""
                "docker exec -it bob /bin/bash -c \"cd /shared/release && make.py 77340-01X -B\""
                ))
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
(with-eval-after-load 'org
  ;Org note stuff
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  (org-babel-do-load-languages 'org-babel-load-languages
 '((python . t)
   (plantuml . t)
   ))

        ;Capture stuff
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
        ;; Kill the frame if one was created for the capturen
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

;(add-to-list 'org-capture-templates
;        '("c" ;Key used to select this template
;        ;template description
;        "Code"
;        ;template type which is a node targeting an org file
;        entry
;        ;template target
;        (file "~/org/captured.org")
;        ;The template for creating the capture item
;        "* Code Snippet %U
;        In ~ [[%F][%f]] ~
;        #+BEGIN_SRC c
;        %i
;        #+END_SRC
;        %?"
;        )
;        '("L"
;        "Protocol Link"
;        entry
;        (file+headline ,(concat org-directory "notes.org") "Inbox")
;        "* %? [[%:link][%(transform-square-brackets-to-round-ones \"%:description\")]]\n")
;        )
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

(use-package! org
  :init
  (setq org-export-creator-string "Reginald Marr"
        org-odt-preferred-output-format "docx"
        org-export-default-language "en"
        org-export-preserve-breaks t
        org-export-headline-levels 3
        org-export-with-toc 3
        )
  )

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
;he was right !
(after! company
  (setq company-idle-delay 0.01))

(use-package org-pdftools
  :hook (org-load . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :after org-noter
  :config
  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))

; PLANTUML
;; (use-package ob-plantuml
;;   :ensure nil
;;   :commands
;;   (org-babel-execute:plantuml)
;;   :defer
;;   :config
;;   (setq plantuml-jar-path (expand-file-name "~/.emacs.d/.local/etc/plantuml.jar")))

;; (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
;; (org-babel-do-load-languages ‘org-babel-load-languages ‘((plantuml . t)))
(with-eval-after-load 'flycheck
  (require 'flycheck-plantuml)
  (flycheck-plantuml-setup))

(defun toggle-maximize-buffer () "Maximize buffer"
  (interactive)
  (if (= 1 (length (window-list)))
      (jump-to-register '_)
    (progn
      (window-configuration-to-register '_)
      (delete-other-windows))))

(map! :leader
      (:prefix "w"
        :desc "Toggle full screen buffer" "f" #'toggle-maximize-buffer))

(map! :leader
      (:prefix "C-t"
        :desc "Open treemacs symbol" "C-t" #'lsp-treemacs-symbols))

(map! :leader
      (:prefix "l"
       :desc "Use the power of thesaurus" "t" #'powerthesaurus-lookup-word-dwim
       :desc "I'm an engineer not a writer" "s" #'ispell))

;I wanna go fast

(add-to-list 'load-path "~/src/elisp/fast-scroll") ; Or wherever you cloned it
(require 'fast-scroll)
;; If you would like to turn on/off other modes, like flycheck, add
;; your own hooks.
(fast-scroll-config)
(fast-scroll-mode 1)
(setq fast-scroll-throttle 0.5)
(shell-command "xset r rate 250 60")
;(use-package! org
;  :config
;  (require 'color)
;  (set-face-attribute 'org-block nil :background
;                      (color-darken-name
;                       (face-attribute 'default :background)  1)))

(load "~/.doom.d/my_email.el")
(setq dired-dwim-target t)

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
