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

(with-eval-after-load 'evil-motion-state-map
  (define-key evil-motion-state-map (kbd "C-o") nil))
;; MAGIT

;;;###autoload
(defun magit-add-all ()
  (interactive)
  (magit-run-git "add" "-A")
  ;; (message "noice")
  )

(defun magit-unadd-all ()
  "Remove all changes from the staging area."
  (interactive)
  (when (or (magit-anything-unstaged-p)
            (magit-untracked-files))
    (magit-confirm 'unstage-all-changes))
  (magit-wip-commit-before-change nil " before unstage")
  (magit-run-git "reset" "HEAD" "--" magit-buffer-diff-files)
  (magit-wip-commit-after-apply nil " after unstage"))

(defun test-msg ()
  (message "test_msg")
  )
;;(magit-reset-hard-upstream)

(define-transient-command magit-reset-hard-upstream ())
;; (define-suffix-command magit-reset-hard-upstream ())
;;;###autoload (autoload 'magit-test "magit-test-commands" nil t)

(define-transient-command magit-test ()
  "Add, configure or remove a branch."
  :man-page "git-branch"
  ["Test"
   ("m" "add all"   magit-add-all)
   ("u" "unadd all" magit-unadd-all)]
  ;;(interactive (list (magit-get-current-branch)))
  ;; (transient-setup 'magit-test nil nil)
  )

(with-eval-after-load 'magit
  ;; Nicer navigation
  (define-key magit-mode-map (kbd "M-j") 'magit-section-forward)
  (define-key magit-mode-map (kbd "M-k") 'magit-section-backward)
  (define-key magit-mode-map (kbd "C-M-j") 'magit-section-forward-sibling)
  (define-key magit-mode-map (kbd "C-M-k") 'magit-section-backward-sibling)
  (define-key magit-mode-map (kbd "C-K") 'magit-section-up)
  (define-key magit-mode-map (kbd "M-o") 'magit-section-toggle)
  (define-key magit-mode-map (kbd "C-o") 'magit-section-cycle)

  ;; Custom Commands
 ;; (transient-append-suffix 'magit-commit "c"
                         ;; '("n" "magit-test" test-msg))



  ;; (transient-append-suffix 'magit-commit "c"
                          ;; '("m" "c2" magit-reset-hard-upstream))
)


 (transient-append-suffix 'magit-commit "c"
                         '("n" "magit-test" magit-test))
