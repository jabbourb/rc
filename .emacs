(require 'cl)
(add-to-list 'load-path "~/.emacs.d/site-lisp")

;;;;;;;;;;;;;;;;;;;; Utilities ;;;;;;;;;;;;;;;;;;;;
(setq browse-url-browser-function 'browse-url-generic)          ;Default browser
(setq browse-url-generic-program "uzbl-browser")


;;;;;;;;;;;;;;;;;;;; L&F ;;;;;;;;;;;;;;;;;;;;
;; Vimpulse (Vim-like keybindings)
(add-to-list 'load-path "~/.emacs.d/site-lisp/vimpulse")
;; Emulate "C-x C-c" on ":q" instead of killing the server
;;(setq vimpulse-want-quit-like-Vim nil)            ;This only deletes the buffer, and doesn't kill the client
(require 'vimpulse)
(setf (cdr (assoc "quit" vimpulse-extra-ex-commands)) '((save-buffers-kill-terminal)))

;; Color theme (manually setting colors doesn't play nicely with emacsclient :(
;;(set-foreground-color "white")
;;(set-background-color "black")
(require 'color-theme)
(color-theme-initialize)
(color-theme-billw)

(set-default-font "Inconsolata 14")
(setq inhibit-splash-screen t)                                  ;Disable the splash screen; also see the --no-splash option
(transient-mark-mode t)                                         ;Show selected area
(global-font-lock-mode t)                                       ;Turn on coloring and fonts
(column-number-mode t)                                          ;Show cursor position in line
(tool-bar-mode -1)                                              ;Hide toolbar (GUI)
(menu-bar-mode -1)                                              ;Hide menubar
(setq scroll-step 1)                                            ;Scroll pages one line at a time
(mouse-wheel-mode t)                                            ;Enable the mouse wheel for scrolling
(scroll-bar-mode -1)                                            ;Hide scroll-bars
(setq display-time-24hr-format t)                               ;Time and date in mode line
(setq display-time-day-and-date t)
(display-time)
(setq case-fold-search t)                                       ;Case insensitive search and autocompletion
(setq read-file-name-completion-ignore-case t)
(defun yes-or-no-p (arg)                                        ;Replace yes-or-no with y-o-n
  "Alias for y-or-n-p"
  (y-or-n-p arg))

(fringe-mode 0)                                                 ;Disable signalling columns

;; Server quirks
;;(add-hook 'server-done-hook 'delete-frame)                        ;Close the client frame after the buffer has been closed
(add-to-list 'default-frame-alist '(font . "Inconsolata 14")) ;Required to set font for every new client frame


;;;;;;;;;;;;;;;;;;;; Unicode ;;;;;;;;;;;;;;;;;;;;
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'latin-1)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)


;;;;;;;;;;;;;;;;;;;; Backups ;;;;;;;;;;;;;;;;;;;;
(setq make-backup-files t)                                      ;Activate automatic backups
(setq version-control t)                                        ;Keep multiple backups
(setq backup-directory-alist '((".*" . "~/.emacs_backups/")))   ;Destination directory
(setq delete-old-versions t)                                    ;Silently overwrite old versions


;;;;;;;;;;;;;;;;;;;; Misc ;;;;;;;;;;;;;;;;;;;;
(defun sort-words ()
  "Sort words in the selected region by alphabetical order"
  (interactive)
  (insert (mapconcat 'identity
             (sort (split-string (delete-and-extract-region
                      (point)
                      (mark)))
               'string<)
             " ")))

(setq write-region-inhibit-fsync t)                             ;Do not force sync while saving (don't spin up hard disk in power saving mode)


;;;;;;;;;;;;;;;;;;;; General Programming ;;;;;;;;;;;;;;;;;;;;
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)      ;Fix junk characters in shell mode
;(define-key global-map (kbd "M-RET") 'hippie-expand)
(global-auto-revert-mode t)                                     ;Auto revert files modified outside Emacs
(setq default-tab-width 4)


;;;;;;;;;;;;;;;;;;;; Code formatting ;;;;;;;;;;;;;;;;;;;;
(vimpulse-map "zz" 'hs-toggle-hiding)
(vimpulse-map "za" 'hs-hide-all)
(vimpulse-map "zn" 'hs-show-all)
(vimpulse-map "\\i" 'indent-region)
(setq viper-auto-indent 1)
(setq tab-always-indent 'complete)

(defun add-format-hook (&rest hooks)
  (dolist (hook hooks)
    (add-hook hook (lambda()
                     (hs-minor-mode 1)                          ;Basic code outlining
                     (setq indent-tabs-mode nil)))))            ;Indent inserts spaces

(add-format-hook 'lisp-mode-hook 'emacs-lisp-mode-hook)


;;;;;;;;;;;;;;;;;;;; Auto-complete ;;;;;;;;;;;;;;;;;;;;
(add-to-list 'load-path "~/.emacs.d/site-lisp/auto-complete")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)

(add-to-list 'load-path "~/.emacs.d/site-lisp/ac-slime")
(require 'ac-slime)

; Clear the default and always use auto-complete
(setq smart-tab-completion-functions-alist nil)

; Set up Lisp completion using ac-slime
(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
; Override local definition of "return" in slime's REPL
(setq ac-use-overriding-local-map 1)


;;;;;;;;;;;;;;;;;;;; Slime ;;;;;;;;;;;;;;;;;;;;
(setq inferior-lisp-program "/usr/bin/sbcl")
(add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
(require 'slime-autoloads)
(slime-setup '(slime-fancy))


;;;;;;;;;;;;;;;;;;;; Org mode ;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-agenda-files (list "~/.emacs.d/todos.org"))           ;Agenda files
;;(setq org-log-done t)                                         ;Show close date for todos
;;(define-key global-map "\C-cl" 'org-store-link)               ;Bindings
;;(define-key global-map "\C-ca" 'org-agenda)


;;;;;;;;;;;;;;;;;;;; Mail ;;;;;;;;;;;;;;;;;;;;
(defun my-mail-mode-hook ()
  (turn-on-auto-fill)                                           ;Wrap lines
  (flush-lines "^\\(> \n\\)*> -- \n\\(\n?> .*\\)*")             ;Kill quoted sigs.
  (not-modified)                                                ;We haven't changed the buffer, haven't we? *g*
  (mail-text)                                                   ;Jump to the beginning of the mail text
  (setq make-backup-files nil))                                 ;Disable backups

(add-to-list 'auto-mode-alist '("mutt-" . mail-mode))
(add-hook 'mail-mode-hook 'my-mail-mode-hook)


;;;;;;;;;;;;;;;;;;;; LaTeX ;;;;;;;;;;;;;;;;;;;;
;;(load "auctex.el" nil t t)
;;(load "preview-latex.el" nil t t)


;;;;;;;;;;;;;;;;;;;; Auto modes ;;;;;;;;;;;;;;;;;;;;
(autoload 'muttrc-mode "muttrc-mode"
  "Major mode to edit muttrc files" t)
(add-to-list 'auto-mode-alist '("muttrc" . muttrc-mode))
(add-to-list 'auto-mode-alist '("/\\.mutt/" . muttrc-mode))

(autoload 'stumpwm-mode "stumpwm-mode"
          "Major mode for editing StumpWM rc files" t)
(add-to-list 'auto-mode-alist '("/\\.stumpwmrc$" . (lambda() (lisp-mode) (stumpwm-mode))))
                                        ;Arch PKGBUILD
(add-to-list 'auto-mode-alist '("/PKGBUILD$" . shell-script-mode))
                                        ; Git commit messages
(add-to-list 'auto-mode-alist '("/COMMIT_EDITMSG$" . (lambda() (diff-mode) (auto-fill-mode) (flyspell-mode))))
                                        ;If no other mode matches
(add-to-list 'auto-mode-alist '("\\`/etc/" . conf-mode) 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(TeX-view-program-list (quote (("zathura" "zathura %o") ("conkeror" "conkeror %o"))))
 '(TeX-view-program-selection (quote ((output-dvi "xdvi") (output-pdf "zathura") (output-html "conkeror"))))
 '(ecb-options-version "2.40"))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
