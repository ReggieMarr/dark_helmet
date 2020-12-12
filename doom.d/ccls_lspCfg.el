;;; ../Downloads/gitDownloads/dark_helmet/doom.d/ccls_lspCfg.el -*- lexical-binding: t; -*-

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
