;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here, run 'doom sync' on
;; the command line, then restart Emacs for the changes to take effect.
;; Alternatively, use M-x doom/reload.


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;(unpin! pinned-package)
;; ...or multiple packages
;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;(unpin! t)


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;(package! some-package)
;
(package! beacon) ;; Never lose your cursor again
(package! calfw)
(package! command-log-mode)
(package! company-quickhelp)
(package! dap-mode)
(package! diredful)
(package! emojify)
(package! erc-image)
(package! flx)
(package! flx-ido)
(package! flyspell-correct-ivy)
(package! helm-recoll)
(package! lispy)
(package! lsp-pyright)
(package! matlab-mode)
(package! nov)
(package! orgit)
(package! org-jira)
(package! org-recoll)
(package! org-latex-impatient)
(package! org-superstar)
(package! ox-hugo)
(package! multiple-cursors)
(package! ob-async) ;asynchonous evaluation of org code blocks
(package! quelpa-use-package)
(package! reddigg)
(package! symbol-overlay)
(package! stickyfunc-enhance)
(package! tab-jump-out)
(package! undo-tree)
(package! use-package)
(package! wucuo) ; Fastest spell checking around
(package! vterm)

;; (package! matrix-client)
(package! matrix-client
  :recipe (:host github :repo "alphapapa/matrix-client.el"))

;; (package! matrix-client
;;   :quelpa matrix-client ( :fetcher github :repo "alphapapa/matrix-client.el"
;;                          :files (:defaults "logo.png" "matrix-client-standalone.el.sh")))
;; (package! matrix-client :recipe
;;   (:host github
;;    :repo "m-fleury/isabelle-release"
;;    :branch "isabelle2019-more-vscode"
;;    :files ("src/Tools/emacs-lsp/lsp-isar/lsp-*.el")))
;; (package! matrix-client
;;   :recipe (:fetcher github :repo "alphapapa/matrix-client.el"
;;                          :files (:defaults "logo.png" "matrix-client-standalone.el.sh")))
;; Telega
;; (package! visual-fill-column)
;; (package! rainbow-identifiers)
;; (package! telega)


;; Not using for now.. pretty buggy
;; (package! pdf-continuous-scroll-mode
;;   :recipe (:host github :repo "dalanicolai/pdf-continuous-scroll-mode.el"))

;; To install a package directly from a particular repo, you'll need to specify
;; a `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
;(package! another-package
;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;(package! this-package
;  :recipe (:host github :repo "username/repo"
;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, for whatever reason,
;; you can do so here with the `:disable' property:
;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;(package! builtin-package :recipe (:nonrecursive t))
;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
;(package! builtin-package :recipe (:branch "develop"))
