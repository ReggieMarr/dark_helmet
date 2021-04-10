;;; ../Downloads/gitDownloads/dark_helmet/doom.d/browser_cfg.el -*- lexical-binding: t; -*-


; web kit stuffs(use-package webkit
(use-package! webkit)
(use-package! webkit-ace) ;; If you want link hinting
(use-package! webkit-dark) ;; If you want to use the simple dark mode

;; See the above explination in the Background section
;; This must be set before webkit.el is loaded so certain hooks aren't installed
;; (setq webkit-own-window t)

;; Set webkit as the default browse-url browser
(setq browse-url-browser-function 'webkit-browse-url)

;; Force webkit to always open a new session instead of reusing a current one
;; (setq webkit-browse-url-force-new t)

;; Globally disable javascript
;; (add-hook 'webkit-new-hook #'webkit-enable-javascript)

;; Override the "loading:" mode line indicator with an icon from `all-the-icons.el'
;; You could also use a unicode icon like ↺
(defun webkit--display-progress (progress)
  (setq webkit--progress-formatted
        (if (equal progress 100.0)
            ""
          (format "%s%.0f%%  " (all-the-icons-faicon "spinner") progress)))
  (force-mode-line-update))

;; Set action to be taken on a download request. Predefined actions are
;; `webkit-download-default', `webkit-download-save', and `webkit-download-open'
;; where the save function saves to the download directory, the open function
;; opens in a temp buffer and the default function interactively prompts.
(setq webkit-download-action-alist '(("\\.pdf\\'" . webkit-download-open)
                                     ("\\.png\\'" . webkit-download-save)
                                     (".*" . webkit-download-default)))

;; Globally use a proxy
;; (add-hook 'webkit-new-hook (lambda () (webkit-set-proxy "socks://localhost:8000")))

;; Globally use the simple dark mode
(setq webkit-dark-mode t)
(use-package evil-collection-webkit
 :config
 (evil-collection-xwidget-setup))

(defun my/eww (url &optional arg buffer)
  "Fetch URL and render the page.
If the input doesn't look like an URL or a domain name, the
word(s) will be searched for via `eww-search-prefix'.

If called with a prefix ARG, use a new buffer instead of reusing
the default EWW buffer.

If BUFFER, the data to be rendered is in that buffer.  In that
case, this function doesn't actually fetch URL.  BUFFER will be
killed after rendering."
  (interactive
   (let ((uris (eww-suggested-uris)))
     (list (read-string (format-prompt "Enter URL or keywords"
                                       (and uris (car uris)))
                        nil 'eww-prompt-history uris)
           (prefix-numeric-value current-prefix-arg))))
  (setq url (eww--dwim-expand-url url))
  (switch-to-buffer
   (cond
    ((eq arg 4)
     (generate-new-buffer "*eww*"))
    ((eq major-mode 'eww-mode)
     (current-buffer))
    (t
     (get-buffer-create "*eww*"))))
  (eww-setup-buffer)
  ;; Check whether the domain only uses "Highly Restricted" Unicode
  ;; IDNA characters.  If not, transform to punycode to indicate that
  ;; there may be funny business going on.
  (let ((parsed (url-generic-parse-url url)))
    (when (url-host parsed)
      (unless (puny-highly-restrictive-domain-p (url-host parsed))
        (setf (url-host parsed) (puny-encode-domain (url-host parsed)))))
    ;; When the URL is on the form "http://a/../../../g", chop off all
    ;; the leading "/.."s.
    (when (url-filename parsed)
      (while (string-match "\\`/[.][.]/" (url-filename parsed))
        (setf (url-filename parsed) (substring (url-filename parsed) 3))))
    (setq url (url-recreate-url parsed)))
  (plist-put eww-data :url url)
  (plist-put eww-data :title "")
  (eww-update-header-line-format)
  (let ((inhibit-read-only t))
    (insert (format "Loading %s..." url))
    (goto-char (point-min)))
  (let ((url-mime-accept-string eww-accept-content-types))
    (if buffer
        (let ((eww-buffer (current-buffer)))
          (with-current-buffer buffer
            (eww-render nil url nil eww-buffer)))
      (eww-retrieve url #'eww-render
                    (list url nil (current-buffer))))))

(defun toggle-emacs-browser ()
    (interactive
        (cond
        ((eq major-mode 'webkit-mode) (my/eww (webkit--get-uri webkit--id)))
        ((eq major-mode 'eww-mode) (webkit-browse-url (plist-get eww-data :url)))
     )))

(setq web-queue '(("Default Page" . "https://www.gnu.org/software/emacs/")))

(defun web-queue-add (url)
    (interactive
        (cond
        ((eq major-mode 'webkit-mode) (my/eww (webkit--get-uri webkit--id)))
        ((eq major-mode 'eww-mode) (webkit-browse-url (plist-get eww-data :url)))
     )))

(map! :leader
      :desc "Toggle Emacs Browser" "t O" #'toggle-emacs-browser)

(map! :leader
      :desc "Read url as org" "t o" #'org-web-tools-read-url-as-org)

(defun my/eww-follow-link (&optional external mouse-event)
  "Browse the URL under point.
If EXTERNAL is single prefix, browse the URL using
`browse-url-secondary-browser-function'.

If EXTERNAL is double prefix, browse in new buffer."
  (interactive
   (list current-prefix-arg last-nonmenu-event)
   eww-mode)
  (mouse-set-point mouse-event)
  (let ((url (get-text-property (point) 'shr-url)))
    (cond
     ((not url)
      (message "No link under point"))
     ((string-match-p eww-use-browse-url url)
      ;; This respects the user options `browse-url-handlers'
      ;; and `browse-url-mailto-function'.
      (my/eww url))
     ((and (consp external) (<= (car external) 4))
      (funcall browse-url-secondary-browser-function url)
      (shr--blink-link))
     ;; This is a #target url in the same page as the current one.
     ((and (url-target (url-generic-parse-url url))
	   (eww-same-page-p url (plist-get eww-data :url)))
      (let ((dom (plist-get eww-data :dom)))
	(eww-save-history)
	(plist-put eww-data :url url)
	(eww-display-html 'utf-8 url dom nil (current-buffer))))
     (t
      (eww-browse-url url external)))))

(require 'org-web-tools)

(map! :leader
      :desc "Insert web link as org link" "i l" #'org-web-tools-insert-link-for-url)
(map! :leader
      :desc "Insert web link as org entry" "i w" #'org-web-tools-insert-web-page-as-entry)

(map! :leader
      :desc "Search url/query with webkit" "g u" #'webkit)

(defun lsp-format-defun ()
  (mark-defun)
  (lsp-format-region))

(map! :leader
      :desc "Format current function" "l F" #'lsp-format-defun)
