(setq user-full-name "Reg Marr"

      user-mail-address "reginald.t.marr@gmail.com"

      doom-scratch-initial-major-mode 'lisp-interaction-mode
      ;;treemacs-width 32 ;;TODO
      doom-theme 'doom-acairo-light

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
  :load-path "/home/rmarr/Downloads/gitDownloads/emacs-libvterm/")

;; (require 'doom-modeline-core)
;; (require 'doom-modeline-segments)
;; (doom-modeline-def-modeline 'my-vterm-mode-line
;;   '(bar workspace-name window-number modals matches buffer-default-directory buffer-info remote-host buffer-position word-count parrot selection-info)
;;   '(objed-state misc-info persp-name battery grip irc mu4e gnus github debug lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs checker))

;; (add-hook! 'vterm-mode-hook (doom-modeline-set-modeline 'my-vterm-mode-line))

;; (with-eval-after-load 'vterm
;;   (evil-define-key '(normal insert) vterm-mode-map
;;     (kbd "M-k") 'vterm-send-up
;;     (kbd "M-j") 'vterm-send-down)
;;   (message "vterm-new-keybindings"))

;; (defun open-named-terminal (termName2)
;;   (vterm)
;;   (rename-buffer termName2 t)
;;   (evil-normal-state)) ;; (unless (display-graphic-p)
;;   (define-key vterm-mode-map [up]    '(lambda () (interactive) (vterm-send-key "<up>")))
;;   (define-key vterm-mode-map [down]  '(lambda () (interactive) (vterm-send-key "<down>")))
;;   (define-key vterm-mode-map [right] '(lambda () (interactive) (vterm-send-key "<right>")))
;;   (define-key vterm-mode-map [left]  '(lambda () (interactive) (vterm-send-key "<left>")))
;;   (define-key vterm-mode-map [tab]   '(lambda () (interactive) (vterm-send-key "<tab>")))
;;   (define-key vterm-mode-map (kbd "DEL") '(lambda () (interactive) (vterm-send-key "<backspace>")))
;;   (define-key vterm-mode-map (kbd "RET") '(lambda () (interactive) (vterm-send-key "<return>"))))
;; (define-key vterm-mode-map (kbd "RET") '(lambda () (interactive) (vterm-send-key "<return>")))

(use-package "fzf" :init(setenv "FZF_DEFAULT_COMMAND" "--type file"))

(use-package symbol-overlay)

(use-package nov)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

;; (map! :leader
;;       (:prefix "c"
;;        :desc "dwim Comment" "Spc" #'comment-dwim))

(map! :leader
  (:prefix "w"
    :desc "Open vterm" "t"    #'vterm)
  (:prefix "b"
    :desc "Switch to buffer" "b" #'switch-to-buffer)
  (:prefix "f"
    :desc "Find file in projects" "f" #'projectile-find-file-in-known-projects)
  :desc "Switchhh" "a" #'switch-to-buffer)

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
(require 'lsp-mode)
(setq ccls-executable "/home/rmarr/.local/bin/ccls")
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection "/home/rmarr/.local/bin/pyls")
                  :major-modes '(python-mode)
                  :server-id 'pyls))
(setq ccls-initialization-options '(:index (:comments 2) :completion (:detailedLabel t)))
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

;; ccls/vars ccls/base ccls/derived ccls/members have a parameter while others are interactive.
;; (ccls/base 1) direct bases
;; (ccls/derived 1) direct derived
;; (ccls/member 2) => 2 (Type) => nested classes / types in a namespace
;; (ccls/member 3) => 3 (Func) => member functions / functions in a namespace
;; (ccls/member 0) => member variables / variables in a namespace
;; (ccls/vars 1) => field
;; (ccls/vars 2) => local variable
;; (ccls/vars 3) => field or local variable. 3 = 1 | 2
;; (ccls/vars 4) => parameter

;; References whose filenames are under this project
;; (lsp-ui-peek-find-references nil (list :folders (vector (projectile-project-root))))
;; (define-key doom-leader-map (kbd "g h") (lambda () (interactive) (ccls/references-not-call ))) ;; (define-key doom-leader-map (kbd "x C") (lambda ()  (ccls/callee )))
;; (define-key doom-leader-map (kbd "x c") (lambda ()  (ccls/caller )))
;; DAP debugging
; Requires pyenv to work properly
(require 'dap-mode)
(require 'dap-ui)
(require 'dap-python)
(dap-mode 1)
(dap-ui-mode 1)
(add-hook 'dap-stopped-hook
          (lambda (arg) (call-interactively #'dap-hydra)))
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
      '("docker exec -it mystifying_bell /bin/bash -c \"cd /shared/kinetis && make -f Make213371\" && scp /home/rmarr/kinetis/213371-01X.axf pyrite:/home/bdi3000/rmarr/"
        "docker exec -it mystifying_bell /bin/bash -c \"cd /shared/kinetis && make -f Make213371 -B\" && scp /home/rmarr/kinetis/213371-01X.axf pyrite:/home/bdi3000/rmarr/"
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
(smartparens-mode 1)
(require 'company)
(setq company-idle-delay 0.2
      company-minimum-prefix-length 3)
(add-hook 'after-init-hook 'global-company-mode)
;;LSP stuff but pertains to company-mode
(setq company-transformers nil company-lsp-async t company-lsp-cache-candidates nil)

;Org mode code capture
;
;; (setq org-capture-templates
;;   '(("c" "Code" entry (file "~/org/captured.org")
;;              "* Code snippet %U\n%(format \"%s\" my-captured-snippet)")))

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
