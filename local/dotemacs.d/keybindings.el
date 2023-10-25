;; Some keybindings

;; The following is going to require some explanation
;; I have decided to switch to konsole because it is:
;;  a) pretty
;;  b) able to deal with 'complex' key sequences 'shift-return'
;; Thus, in my konsole configuration I did the following:
;;  a) Set the XFree86 keybinding for "Return+Shift" to the sequence: \E[27~
;;     Theoretically this should read as escape-[27;3, but I think I do not understand key sequences fully.
;;  b) Restarted konsole
;;  c) Opened the scratch buffer and did (read-key-sequence-vector "hi") and then hit shift-return
;; (read-key-sequence-vector "hi")
;;   Note, previously I set it to \E[27;3 but that seems to have stopped working in new konsole.
;; It printed the vector [27 91 50 55 126]
;; So I came here and did the following line:
(define-key function-key-map [27 91 50 55 126] [(shift return)])
(define-key function-key-map [menu] [(C-return)])
(define-key function-key-map [27 91 49 59 53 99] [(C-right)])
(define-key function-key-map [27 91 49 59 53 100] [(C-left)])
(global-set-key [(C-right)] 'right-word)
(global-set-key [(C-left)] 'left-word)
;; Now as long as I have the same konsole keyboard configuration, I should be able to hit shift-enter.
;; and get the same thing as shift-return in X.

(global-set-key (kbd "C-]") 'forward-char)
(global-set-key (kbd "<prior>") 'sfp-page-up)
(global-set-key (kbd "<next>") 'sfp-page-down)
;;(define-key global-map (kbd "C-c C-c") nil)
;;(global-set-key (kbd "C-c C-c") 'cua-copy-region)
(global-set-key (kbd "M-c") 'cua-copy-region)
(global-set-key (kbd "M-v") 'cua-paste)
(global-set-key "\M-/" 'ac-start)
(global-set-key (kbd "C-c C-f") 'my-set-frame-name)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-k") 'kill-line)
(global-set-key (kbd "C-a") 'beginning-of-line)
(global-set-key (kbd "C-e") 'end-of-line)
(global-set-key (kbd "s-a") 'beginning-of-buffer)
;; Something in MATE's keyboard configuration is grabbing s-e and invoking the file manager.
(global-set-key (kbd "s-e") 'end-of-buffer)

(global-set-key [drag-mouse-0] 'mouse-set-point)
(global-set-key (kbd "<tab>") 'company-indent-or-complete-common)

(define-key comint-mode-map (kbd "C-k") 'kill-line)

(with-eval-after-load "haskell-mode"
  (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
  (define-key haskell-mode-map (kbd "C-`") 'haskell-interactive-bring)
  (define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
  (define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
  (define-key haskell-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
  (define-key haskell-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
  (define-key haskell-mode-map (kbd "C-c c") 'haskell-process-cabal)
  (define-key haskell-mode-map (kbd "SPC") 'haskell-mode-contextual-space))

;(with-eval-after-load "helm-mode"
;  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action))

(with-eval-after-load "ivy"
     ;;(defun eh-ivy-partial-or-done ()
     ;;  (interactive)
     ;;  (or (ivy-partial)
     ;;      (ivy-alt-done)))
     ;;(define-key ivy-minibuffer-map (kbd "TAB") 'eh-ivy-partial-or-done)
  ;;(require 'ivy)
  (define-key ivy-minibuffer-map (kbd "TAB") 'ivy-partial))

(with-eval-after-load "js2-mode"
  (define-key js2-mode-map [(shift return)] 'nodejs-repl-send-line))

;; reminders to self
;; shell-script-mode: sh-mode: for writing code
;; shell-mode: shell-mode: for running the shell
;; the shell script mode's map: sh-mode-map
;; the shell's mode map: shell-mode-map?  uncertain.
(with-eval-after-load "sh-script"
  (define-key sh-mode-map [(shift return)] 'eir-eval-in-shell))
(with-eval-after-load "shell"
  (define-key shell-mode-map (kbd "C-z") 'comint-stop-subjob)
  (define-key shell-mode-map (kbd "RET") 'shell-bottom))
(with-eval-after-load "python"
  (define-key sh-mode-map [(shift return)] 'eir-eval-in-python))
(with-eval-after-load "slime"
  (define-key slime-mode-map [(shift return)] 'eir-eval-in-slime)
  (setq slime-protocol-version 'ignore
        slime-net-coding-system 'utf-8-unix
        slime-complete-symbol*-fancy t
        slime-complete-symbol-function 'slime-fuzzy-complete-symbol))
