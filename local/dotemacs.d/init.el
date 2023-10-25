;; Some notes on use-package
;; If aI want to use a locally installed package in the packages/ directory
;; then I need to make sure that :ensure is nil
;; but I will also be responsible for making sure it gets loaded at the correct time.
;; this is most notable when dealing with polymode shenanigans

(require 'cl-lib)
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
;; load some random functions I have stolen/written
(load-file "~/.emacs.d/functions.el")

;; Adding some new stuff from:
;; https://www.lucacambiaghi.com/vanilla-emacs/readme.html#h:06BE4AA2-688D-4748-BF6D-9656EF6ED767
;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font. By inhibiting this, we easily halve startup times with fonts that are
;; larger than the system default.
(setq frame-inhibit-implied-resize t)

;; I can never remember the commands to update packages in emacs:
;; (list-packages)
;; Then type 'U' to mark available updates, 'x' to do the upgrade.

(require 'package)
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("gnu-devel" . "https://elpa.gnu.org/devel/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; marmalade seems to be down?
;;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu-mirror" . "https://gitlab.com/d12frosted/elpa-mirror/raw/master/gnu/"))
(add-to-list 'package-archives '("melpa-mirror" . "https://gitlab.com/d12frosted/elpa-mirror/raw/master/melpa/"))

(setq package-check-signature nil)
;(package-initialize)
;;(package-refresh-contents)

(package-install 'use-package)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(require 'use-package)
(setq use-package-always-ensure t)
(straight-use-package 'use-package)
(straight-use-package 'org)

;; Another block from Luca Cambiaghi, I did not realize one can use use-package on emacs itself.
;; so I decided I would grab it and move some of my various setqs here.
(use-package emacs
  :init
  (defalias 'yes-or-no-p 'y-or-n-p)
  (setq
   enable-local-variables :all ; fix =defvar= warnings
   inhibit-startup-screen t
   initial-scratch-message nil
   sentence-end-double-space nil
   ring-bell-function 'ignore
   frame-resize-pixelwise t
   user-full-name "Ashton Belew"
   user-mail-address "abelew@gmail.com"
   vc-follow-symlinks t     ;; follow symlinksa
   read-process-output-max (* 1024 1024))
  ;; default to utf-8 for all the things
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))
  ;; write over selected text on input... like all modern editors do
  (delete-selection-mode t)
  ;; enable recent files mode.
  (recentf-mode t)
  (setq recentf-exclude `(,(expand-file-name "straight/build/" user-emacs-directory)
                          ,(expand-file-name "eln-cache/" user-emacs-directory)
                          ,(expand-file-name "etc/" user-emacs-directory)
                          ,(expand-file-name "var/" user-emacs-directory)))
  ;; don't show any extra window chrome
  (when (window-system)
    (tool-bar-mode -1)
    (toggle-scroll-bar -1))
  ;; enable winner mode globally for undo/redo window layout changes
  (winner-mode t)
  (show-paren-mode t)
  ;; less noise when compiling elisp
  (setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))
  (setq native-comp-async-report-warnings-errors nil)
  (setq load-prefer-newer t)
  ;; use common convention for indentation by default
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2))

;; downloads and makes icons available for lots of modes. It might only work
;; when (display-graphic-p), which is not something I do very often.
(use-package all-the-icons)

;; Adds reasonably nice, and modifyable completions to shell-mode.
(use-package bash-completion
  :config
  (autoload 'bash-completion-dynamic-complete
    "bash-completion"
    "BASH completion hook")
  (add-hook 'shell-dynamic-complete-functions
            'bash-completion-dynamic-complete))

(defun atb/benchmark-init-deactivate ()
  (interactive)
  (benchmark-init/deactivate)
  (message "Emacs loaded in %s seconds with %d gcs."
           (format "%.2f" (float-time (time-subtract after-init-time before-init-time)))
           gcs-done))
(use-package benchmark-init
  :config
  (add-hook 'after-init-hook 'atb/benchmark-init-deactivate))

(use-package code-cells
  :config
  (add-hook 'code-cells-mode-hook 'code-cells-convert-ipynb)
  :mode
  ("\\.ipynb$" . code-cells-mode))

;; Looks like a neat toy!
;(use-package combobulate
;  :hook
;  ((python-ts-mode . combobulate-mode)
;   (js-ts-mode . combobulate-mode)
;   (css-ts-mode . combobulate-mode)
;   (yaml-ts-mode . combobulate-mode)
;   (typescript-ts-mode . combobulate-mode)
;   (tsx-ts-mode . combobulate-mode)))

;; The mode that seeks to "complete-anything"
(use-package company
  :custom
  (company-minimum-prefix-length 2)
  (company-idle-delay 1)
  :bind* ("\t" . #'company-indent-or-complete-common)
  :hook (after-init . global-company-mode)
  :config
  (define-key company-active-map "\t" 'company-indent-or-complete-common))

(use-package company-jedi)

(use-package company-posframe
  :config (company-posframe-mode 1))

;; Adds cute icons when using company, maybe needs
;; (graphics-p) to be t
(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package coterm
  :commands shell
  :config
  (setq coterm-mode t))

(use-package csv-mode
  :hook (csv-mode . lc/init-csv-mode))

(use-package deadgrep)

;; Remind me when it would be good to wrap.
(use-package display-fill-column-indicator
  :config (global-display-fill-column-indicator-mode)
  :custom (display-fill-column-indicator-column 100))

;; Extra pretty modeline, which might also require graphics...
(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;;(use-package eglot
;;  :ensure t
;;  :config
;;  (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))
;;  (setq-default
;;   eglot-ignored-server-capabilities '(:documentFormattingProvider)
;;   eglot-workspace-configuration
;;   '((:pylsp . (:configurationSources ["flake8"] :plugins
;;                                      (:pycodestyle (:enabled nil) :mccabe (:enabled nil)
;;                                                    :flake8 (:enabled t))))))
;;  :hook
;;  ((elpy-mode . eglot-ensure)
;;   (python-mode . eglot-ensure)
;;   (ess-r-mode . eglot-ensure)))

;; jupyter in emacs
(use-package ein
  :commands ein:run
  :config
  (setq ein:console-args '("--profile" "default"))
  (setq ein:console-security-dir "~/.emacs.d/ein")
  (setq ein:polymode t)
  (add-hook 'ein:connect-mode-hook 'ein:jedi-setup)
  (require 'ein)
  (require 'ein-notebook))

;; provides documentation strings.
(use-package eldoc
  :config
  (setq eldoc-idle-delay 3)
  (add-to-list 'display-buffer-alist
               '("^\\*eldoc for" display-buffer-at-bottom
                 (window-height . 3))))

;; Full IDE toys for python
(with-eval-after-load 'elpy (progn (elpy-enable)
                                   (atb/auto-venv-activate)))
(use-package elpy
  :ensure t
  :init (elpy-enable)
  :config
  (setq python-shell-interpreter "python"
        python-shell-interpreter-args "-i"
        ;;elpy-rpc-backend "rope"
        python-indent-guess-indent-offset-verbose nil ;; stop telling me you can't guess.
        python-indent-guess-indent-offset t ;; but please guess because I don't trust anyone.
        python-shell-enable-font-lock t
        elpy-shell-codecell-beginning-regexp "^```{python.*}$"
        elpy-shell-cell-boundary-regexp "^```$\\|^```{python.*}$"
        elpy-shell-starting-directory (quote current-directory))
  ;; elpy-rpc-virtualenv-path "venv"
  (add-to-list 'python-shell-completion-native-disabled-interpreters "jupyter")
  (define-key elpy-mode-map [(shift return)] 'eir-eval-in-python)
  ;; (define-key elpy-mode-map [(shift return)] 'python-shell-send-paragraph-and-step)
  (define-key inferior-python-mode-map (kbd "C-g C-g") 'atb/interrupt-python)
  (define-key elpy-mode-map (kbd "M-[ z") 'elpy-company-backend)
  (define-key python-mode-map "\t" 'company-indent-or-complete-common)
  (when (load "flycheck" t t)
    (setq flycheck-python-pycompile-executable "python")
    ;;(setq flycheck-python-pylint-executable "flake8")
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules)))
  ;(venv-initialize-interactive-shells)
  (global-company-mode 1)
  ;(venv-initialize-eshell)
  (add-hook 'python-mode-hook #'atb/auto-venv-activate)
  (add-hook 'elpy-mode-hook #'atb/auto-venv-activate)
  :bind*
  (:map elpy-mode-map
        ("\t" . company-indent-or-complete-common)
        ([(shift return)] . eir-eval-in-python)
        ([(control return)] . python-shell-send-paragraph-and-step))
  (:map python-mode-map
        ("\t" . company-indent-or-complete-common)))
  ;;:hook ((elpy-mode . flycheck-mode)))

;; emacs speaks statistics
(defun atb/ess-settings ()
  ;; something else is using setq-local on the indentation settings and overwriting my choice.
  ;; However, if I do a setq-local back at it, it is maintained.
  (setq-local ess-indent-offset 2)
  (ess-set-style 'RStudio))
(use-package ess
  :straight (ess :type git :host github :repo "emacs-ess/ESS")
  :mode
  (("\\.Rd$" . R-mode)
   ("\\.R$" . R-mode))
  :bind*
  (:map ess-mode-map
        ("\t" . company-indent-or-complete-common)
        ("M-P" . my/add-pipe)
        ("M-h" . company-show-doc-buffer)
        ("C-c C-n" . atb/ess-eval)
        ("C-=" . atb/insert-arrow)
        ("M-=" . atb/insert-arrow)
        ("s-=" . atb/insert-arrow-spaces)
        ([(shift return)] . atb/ess-eval))
  :hook (ess-mode . atb/ess-settings)
  :init
  (company-posframe-mode 0)
  (add-hook 'ess-mode-hook
            (lambda()
              (make-local-variable 'company-backends)
              (setq company-backends '(company-files company-capf-with-R-objects))))
  :config
  (require 'ess-site)
  (require 'ess-julia)
  (ess-set-style 'RStudio)
  ;; (ess-toggle-underscore nil)
  ;; https://github.com/emacs-ess/ESS/issues/1146
  (setq
   comint-prompt-read-only nil
   comint-use-prompt-regexp nil
   ansi-color-for-comint-mode 'filter
   ess-ask-for-ess-directory nil
   ess-can-eval-in-background nil
   ess-offset-continued 2
   ess-indent-offset 2
   ess-indent-with-fancy-comments nil
   ess-r--no-company-meta t
   ess-roxy-hide-show-p "Off"
   ess-startup-directory 'default-directory
   ess-use-flymake nil
   ;; From: https://github.com/emacs-ess/ESS/issues/973
   ess-use-tracebug nil
   inhibit-field-text-motion nil)
  ;; Trying again to stop stupid 'Text is read-only' message.
  (add-hook 'inferior-ess-mode-hook
            (lambda ()
              (setq-local bidi-display-reordering nil)
              (setq-local inhibit-field-text-motion nil)
              (setq-local comint-use-prompt-regexp nil)))
  (local-set-key (kbd "C-k") 'kill-line)
  (local-set-key (kbd "C-a") 'beginning-of-line)
  (local-set-key (kbd "C-e") 'end-of-line)
  ;; (defvar ess-r-backend 'ess)
  ;; trying out lsp
  (defvar ess-r-backend 'ess
    "The backend to use for IDE features. Possible values are `ess' and `lsp'.")
  (defvar ess-assign-key nil
    "Call `ess-insert-assign'.")
  ;; the following is the only thing I have found to remap tab in ess
  (define-key ess-mode-map "\t" 'company-indent-or-complete-common))

;; In theory I am interested in using lsp with ess, but in practice
;; that combination along with polymode causes problems.
;(use-package ess-site
;  :bind* ("\t" . #'company-indent-or-complete-common)
;  :mode
;  (("\\.Rd$" . R-mode)
;   ("\\.R$" . R-mode))
;  ;; :hook (R-mode . lsp-deferred)
;  :commands R)

;; nicely removes trailing whitespace
(use-package ethan-wspace
  :config
  (setq mode-require-final-newline nil)
  (global-ethan-wspace-mode 1))

;; also known as eir, in theory should make many/most shells act like ess/R
;; One of the stranges behaviors I have noticed in a long time is the fact that
;; I could trivially set up a ielm config using use-package, but my every attempt
;; to duplicate that for shell failed.  However, in the keybindings.el
;; file I was able to get it to work with an (eval-after-load "sh-script")
;; invocation
(use-package eval-in-repl
  :config
  (setq eir-repl-placement 'right)
  (setq eir-always-split-screen-window t)
  (load-library "eval-in-repl-ielm")
  (load-library "eval-in-repl-shell")
  (load-library "eval-in-repl-python")
  :bind
  (:map emacs-lisp-mode-map ([(shift return)] . eir-eval-in-ielm))
  (:map python-mode-map ([(shift return)] . eir-eval-in-python))
  )

;; commenting shortcut library, looks neat
(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package flycheck
  :ensure t
  ;; :init (global-flycheck-mode)
  :hook ((flycheck-mode . my-flycheck-prefer-eldoc))
  :config
  (setq flycheck-idle-change-delay 2
        flycheck-idle-buffer-switch-delay 2
        flycheck-check-syntax-automatically '(save idle-change mode-enabled)
        flycheck-flake8-maximum-line-length 100
        ;flycheck-lintr-linters "withr::with_namespace(package = 'hpgltools', code = {linters_with_defaults(line_length_linter(100))})"
        flycheck-lintr-caching t)
  (add-to-list 'flycheck-checkers 'proselint)
  (setq-default flycheck-highlighting-mode 'lines))

(flycheck-define-checker proselint
  "A linter for prose."
  :command ("proselint" source-inplace)
  :error-patterns
  ((warning line-start (file-name) ":" line ":" column ": "
            (id (one-or-more (not (any " "))))
            (message (one-or-more not-newline)
                     (zero-or-more "\n" (any " ") (one-or-more not-newline)))
            line-end))
  :modes (text-mode markdown-mode gfm-mode org-mode))

;; fuzzy file finder
(use-package fzf)

;; changes gc threshold depending on system usage.
(use-package gcmh
  :demand
  :config
  (gcmh-mode 1))

(use-package geiser
  :bind (:map scheme-mode-map
              ([(shift return)] . eir-eval-in-geiser)))

(use-package geiser-guile)

;; System for making binding keys easier
(use-package general
  :config
  (general-define-key
   :keymaps 'org-mode-map
   "C-c C-q" 'counsel-org-tag))

(use-package git-gutter
  :config (global-git-gutter-mode 't))

(use-package go-mode
  :config
  (add-hook 'before-save-hook 'gofmt-before-save))

(use-package goto-last-change
  :bind (("C-;" . goto-last-change)))

(use-package haskell-mode)

(use-package hide-mode-line
  :defer t)

(use-package hindent)

;; improved help!
(use-package helpful
  :straight (helpful :type git :host github :repo "Wilfred/helpful")
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :defer nil
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

(use-package highlight-indentation
  :config (setq highlight-indentation-blank-lines t))

;;(use-package inferior-python-mode
;;  :hook (inferior-python-mode . hide-mode-line-mode))

(use-package js3-mode
  :defer t)

(use-package js2-mode
  :defer t
  :mode "\\.js$"
  :interpreter "node"
  :bind
  (:map js2-mode-map
        ("M-r"        . node-js-eval-region-or-buffer)
        ("M-R"        . refresh-chrome)
        ("M-s-<up>"   . js2r-move-line-up)
        ("M-s-<down>" . js2r-move-line-down)
        ("C-<left>"   . js2r-forward-barf)
        ("C-<right>"  . js2r-forward-slurp)
        ("M-m S"      . js2r-split-string))
  :config
  (setq-default js2-concat-multiline-strings 'eol)
  (setq-default js2-global-externs '("module" "require" "setTimeout" "clearTimeout" "setInterval"
                                     "clearInterval" "location" "__dirname" "console" "JSON" "window"
                                     "process" "fetch"))
  (setq-default js2-strict-trailing-comma-warning t)
  (setq-default js2-strict-inconsistent-return-warning nil)
  (use-package prettier-js)
  (use-package rjsx-mode
    :mode "\\.jsx$"
    :magic ("import React" . rjsx-mode))
  (use-package js2-refactor)
  (use-package json-mode)
  (use-package nodejs-repl)
  (add-hook 'js2-mode-hook #'js2-refactor-mode)
  (add-hook 'js2-mode-hook
            '(λ ()
                (js2-refactor-mode)
                (js2r-add-keybindings-with-prefix "M-m")
                (key-chord-define js2-mode-map ";;" (λ (save-excursion (move-end-of-line nil) (insert ";"))))
                (key-chord-define js2-mode-map ",," (λ (save-excursion (move-end-of-line nil) (insert ","))))

                (define-key js2-mode-map (kbd ";")
                            (λ (if (looking-at ";")
                                   (forward-char)
                                 (funcall 'self-insert-command 1))))
                ;; Overwrite this function to output to minibuffer
                (defun nodejs-repl-execute (command &optional buf)
                  "Execute a command and output the result to minibuffer."
                  (let ((ret (nodejs-repl--send-string (concat command "\n"))))
                    (setq ret (replace-regexp-in-string nodejs-repl-ansi-color-sequence-re "" ret))
                    ;; delete inputs
                    (setq ret (replace-regexp-in-string "\\(\\w\\|\\W\\)+\r\r\n" "" ret))
                    (setq ret (replace-regexp-in-string "\r" "" ret))
                    (setq ret (replace-regexp-in-string "\n.*\\'" "" ret))
                    (setq ret (replace-regexp-in-string "\nundefined\\'" "" ret))
                    (message ret)))
                (defadvice nodejs-repl (after switch-back activate)
                  (delete-window)))))

(use-package live-py-mode)

(use-package magit
  :bind ("C-x g" . magit-status)
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package marginalia
  :after vertico
  :custom (marginalia-annotators '(marinalia-annotators-heavy marinalia-annotators-light nil))
  :init (marginalia-mode))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode
  (("README\\.md$" . gfm-mode)
   ("\\.md$" . markdown-mode)
   ("\\.markdown$" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package modus-themes
  :init
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs nil
        modus-themes-region '(bg-only no-extend))
  :config
  ;; Load the theme of your choice:
  (load-theme 'modus-vivendi t))

(use-package nerd-icons
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))

;; an epub reader
(use-package nov
  :mode (("\\.epub$" . nov-mode)))

(use-package numpydoc
  :ensure t
  :defer t
  :custom
  (numpydoc-insert-examples-block nil)
  (numpydoc-template-long nil)
  :bind (:map python-mode-map
              ("C-c C-n" . numpydoc-generate)))

(use-package ob-racket
  :straight (ob-racket
             :type git :host github :repo "hasu/emacs-ob-racket"
             :files ("*.el" "*.rkt"))
  :after org
  :config
  (add-hook 'ob-racket-pre-runtime-library-load-hook
            #'ob-racket-raco-make-runtime-library))

;; Distraction-free screen
(use-package olivetti
  :defer t
  :init
  (setq olivetti-body-width .67)
  :config
  (defun distraction-free ()
    "Distraction-free writing environment"
    (interactive)
    (if (equal olivetti-mode nil)
        (progn
          (window-configuration-to-register 1)
          (delete-other-windows)
          (text-scale-increase 2)
          (olivetti-mode t))
      (progn
        (jump-to-register 1)
        (olivetti-mode 0)
        (text-scale-decrease 2))))
  :bind
  (("<f9>" . distraction-free)))

(use-package ob-ipython)

(use-package org
  :straight t
  :commands (org-capture org-agenda)
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (setq org-agenda-start-with-log-mode t)
  (setq org-return-follows-link 1)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-files '("~/org/tasks.org"))
  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
          (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))
  (setq org-refile-targets
        '(("Archive.org" :maxlevel . 1)
          ("Tasks.org" :maxlevel . 1)))
  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)
  (setq org-confirm-babel-evaluate nil)
  ;; (setq org-babel-default-header-args to something, it defines the header variables)
  (setq org-src-fontify-natively t)
  (setq org-src-preserve-indentation nil)
  (setq org-edit-src-content-indentation 0)
  (setq ob-async-no-async-languages-alist '("ipython"))
  (add-hook 'org-babel-after-execute-hook 'org-display-inline-images)
  (add-hook 'org-mode-hook 'org-display-inline-images)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (R . t)
     (shell . t)
     (ipython . t)
     (racket . t)
     (scheme . t)
     ;; (ein . t)
     (python . t)))
  (push '("conf-unix" . conf-unix) org-src-lang-modes)
  ;; This is needed as of Org 9.2
  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("sc" . "src scheme :session"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("R" . "src R :session"))
  (add-to-list 'org-structure-template-alist '("py" . "src python :session"))
  (setq org-tag-alist
        '((:startgroup)
          ;; Put mutually exclusive tags here
          (:endgroup)
          ("@errand" . ?E)
          ("@home" . ?H)
          ("@work" . ?W)
          ("agenda" . ?a)
          ("planning" . ?p)
          ("publish" . ?P)
          ("batch" . ?b)
          ("note" . ?n)
          ("idea" . ?i)))
  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
        '(("d" "Dashboard"
           ((agenda "" ((org-deadline-warning-days 7)))
            (todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))
            (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))
          ("n" "Next Tasks"
           ((todo "NEXT"
                  ((org-agenda-overriding-header "Next Tasks")))))
          ("W" "Work Tasks" tags-todo "+work-email")
          ;; Low-effort next actions
          ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
           ((org-agenda-overriding-header "Low Effort Tasks")
            (org-agenda-max-todos 20)
            (org-agenda-files org-agenda-files)))
          ("w" "Workflow Status"
           ((todo "WAIT"
                  ((org-agenda-overriding-header "Waiting on External")
                   (org-agenda-files org-agenda-files)))
            (todo "REVIEW"
                  ((org-agenda-overriding-header "In Review")
                   (org-agenda-files org-agenda-files)))
            (todo "PLAN"
                  ((org-agenda-overriding-header "In Planning")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "BACKLOG"
                  ((org-agenda-overriding-header "Project Backlog")
                   (org-agenda-todo-list-sublevels nil)
                   (org-agenda-files org-agenda-files)))
            (todo "READY"
                  ((org-agenda-overriding-header "Ready for Work")
                   (org-agenda-files org-agenda-files)))
            (todo "ACTIVE"
                  ((org-agenda-overriding-header "Active Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "COMPLETED"
                  ((org-agenda-overriding-header "Completed Projects")
                   (org-agenda-files org-agenda-files)))
            (todo "CANC"
                  ((org-agenda-overriding-header "Cancelled Projects")
                   (org-agenda-files org-agenda-files)))))))
  (define-key global-map (kbd "C-c j")
              (lambda () (interactive) (org-capture nil "jj")))
  ;;  (efs/org-font-setup))
  )

(use-package org-modern
  :custom
  (org-modern-hide-stars t) ; adds extra indentation
  (org-modern-table nil)
  (org-modern-list
   '(;; (?- . "-")
     (?* . "•")
     (?+ . "‣")))
  :config
  (with-eval-after-load 'org (global-org-modern-mode))
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda))

(use-package org-modern-indent
  :straight (org-modern-indent :type git :host github :repo "jdtsmith/org-modern-indent")
  :config
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

(use-package org-roam
  :custom
  (org-roam-directory "~/roam")
  (org-roam-completion-everywhere t)
  :bind
  (("C-c n l" . org-roam-buffer-toggle)
   ("C-c n f" . org-roam-node-find)
   ("C-c n i" . org-roam-node-insert)
   :map org-mode-map ("C-M-i" . completion-at-point))
  :config (org-roam-setup))

(use-package pacmacs)

(use-package paren
  :config
  (set-face-background 'show-paren-match (face-background 'default))
  (set-face-foreground 'show-paren-match "#def")
  (set-face-attribute 'show-paren-match nil :weight 'extra-bold))

(use-package perl-mode
  :hook (perl-mode . lsp-deferred))

(use-package poetry
  :ensure t
  :defer t
  :config
  (setq poetry-tracking-strategy 'switch-buffer)
  (setenv "WORKON_HOME" "~/.cache/pypoetry/virtualenvs"))

(use-package polymode
  :ensure t
  :init
  :config
  (define-hostmode my/poly-guile-hostmode)
  (define-innermode my/poly-guile-markdown-innermode
    :mode 'scheme-mode
    :name "guile cell"
    :head-matcher (rx bol ?# ? (>= 1 ?*) (* nonl) ?\n
                      "'''{guile" (* nonl) ?\n)
    :tail-matcher (rx bol "'''" (* nonl) ?\n)
    :head-mode 'host
    :tail-mode 'host
    :adjust-face nil)
  (define-polymode my/poly-guile-mode
    :hostmode 'my/poly-guile-hostmode
    :innermodes '(my/poly-guile-markdown-innermode))

  (define-hostmode my/poly-python-hostmode)
  (define-innermode my/poly-python-markdown-innermode
    :mode 'markdown-mode
    :name "Markdown Cell"
    :head-matcher (rx bol ?# ? (>= 1 ?*) (* nonl) ?\n
                      "'''{python" (* nonl) ?\n)
    :tail-matcher (rx bol "'''" (* nonl) ?\n)
    :head-mode 'host
    :tail-mode 'host
    :adjust-face nil
    :init-functions '(my/lsp-conduit))
  (define-polymode my/poly-python-mode
    :hostmode 'my/poly-python-hostmode
    :innermodes '(my/poly-python-markdown-innermode))
  :hook
  ((python-mode . my/poly-python-mode)
   (scheme-mode . my/poly-guile-mode)
  ;;   (python-mode . eglot-ensure)
   (python-mode . company-mode)))

(use-package poly-R
  :straight (poly-R :type git :host github :repo "polymode/poly-R")  
  :ensure t
  :after 'polymode
  :mode
  (("\\.Rmd$" . poly-markdown+r-mode)
   ("\\.jmd$" . poly-markdown-mode)))
(use-package poly-markdown
  :ensure t
  :mode
  (("\\.md$" . poly-markdown-mode))
  :after 'polymode)
(use-package poly-org
  :straight (poly-org :type git :host github :repo "polymode/poly-org")    
  :after 'polymode
  :mode
  (("\\.org$" . poly-org-mode)))
(use-package poly-noweb
  :after 'polymode)
(use-package poly-rst
  :after 'polymode)
;; I know this is against the spirit of use-package, but wtf.
(load-library "poly-markdown")
(load-library "poly-R")

(use-package posframe)

(use-package projectile
  :diminish projectile-mode
  ;; :custom ((projectile-completion-system 'ivy))
  :bind-keymap ("C-c p" . projectile-command-map)
  :config
  (projectile-mode)
  (setq projectile-enable-caching t)
  (setq projectile-project-root ".projectile"))
  ;; (setq venv-dirlookup-names '(".projectile" "venv" ".venv" "pyenv" ".pyenv" ".virtual")))

;(use-package pyvenv
;  :config
;  (pyvenv-mode 1))

(use-package racket-mode)

(use-package rainbow-mode
  :config
  (setq rainbow-x-colors nil)
  (add-hook 'prog-mode-hook 'rainbow-mode))

(use-package rainbow-delimiters
  :commands (rainbow-delimiters-mode)
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rust-mode)

(use-package savehist
  :init (savehist-mode))

(use-package shell
  :after comint shell-script eval-in-repl
  :bind
  (:map sh-mode-map
        ([(shift return)] . eir-eval-in-shell))
  (:map shell-mode-map
        ("C-z" . comint-stop-subjob)
        ("RET" . shell-bottom))
  :config
  (setq
   ansi-color-for-comint-mode 'filter
   comint-use-prompt-regexp nil
   inhibit-field-text-motion nil
   comint-prompt-read-only nil
   comint-input-ignoredups t
   comint-process-echoes t
   comint-prompt-read-only nil
   comint-scroll-to-bottom-on-input t
   comint-scroll-to-bottom-on-output t
   comint-move-point-for-output t
   comint-scroll-show-maximum-output t
   comint-input-ring-size 1000))

(use-package sicp)

(use-package slime)

;;(use-package tree-sitter
;;  :config (global-tree-sitter-mode))
;;;;(use-package tree-sitter-langs)

(use-package vertico
  :custom (vertico-cycle t)
  :init (vertico-mode))

;(use-package virtualenvwrapper
;  :commands venv-initialize-interactive-shells)

(use-package vterm
  :defer t
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")  ;; Set this to match your custom shell prompt
  ;;(setq vterm-shell "zsh")                       ;; Set this to customize the shell to launch
  (setq vterm-max-scrollback 10000))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idel-delay 1))

(use-package yaml-mode
  :commands (yaml-mode))

(use-package zotxt)

(load-file "~/.emacs.d/config.el")
(load-file "~/.emacs.d/keybindings.el")
(load-file "~/.emacs.d/zw-company.el")
(load-theme 'modus-vivendi t)
