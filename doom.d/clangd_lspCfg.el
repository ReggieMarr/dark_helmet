;;; ../Downloads/gitDownloads/dark_helmet/doom.d/clangd_lspCfg.el -*- lexical-binding: t; -*-


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
