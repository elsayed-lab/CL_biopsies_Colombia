;; Something changed in the git branch of emacs 29 which causes
;; C-k C-y to fail with 'undefined x-cut-buffer-or-selection-value.
;; Mysteriously, the following fixes it, as per a google search leading to stack overflow.
(setq interprogram-paste-function 'gui-selection-value)
;; (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)


(defalias 'yes-or-no-p 'y-or-n-p)

;; Screen and emacs are constantly fighting over the title and it is annoying.
(setq frame-title-format nil)
;; Sadly, setting frame-title-format to nil did not fix this.
;;(setq frame-title-format
;;      '("" invocation-name ": "(:eval (if (buffer-file-name)
;;                                          (abbreviate-file-name (buffer-file-name))
;;                                        "%b %S: %f line: %l column: %c"))))

;; Something changed in the git branch of emacs 29 which causes
;; C-k C-y to fail with 'undefined x-cut-buffer-or-selection-value.
;; Mysteriously, the following fixes it, as per a google search leading to stack overflow.
(setq interprogram-paste-function 'gui-selection-value)

;; pretty colors in comint-mode
(ansi-color-for-comint-mode-on)
;; decompress on the fly
(auto-compression-mode t)
;; my fingers never stopped hitting ctrl-c/ctrl-v
(cua-mode 1)
(global-auto-revert-mode 1)
(global-ethan-wspace-mode 1)
(global-font-lock-mode t)
(global-subword-mode 1)
(global-hl-line-mode +1)
;;(global-undo-tree-mode)
(make-variable-buffer-local 'transient-mark-mode)
(put 'transient-mark-mode 'permanent-local t)
(save-place-mode 1)
(show-paren-mode 1)
(transient-mark-mode 1)
(xterm-mouse-mode nil)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(add-hook 'auto-save-hook 'save-buffer-if-visiting-file)

(setq-default indent-tabs-mode nil)
(setq
 abbrev-mode t
 auto-save-interval 3000
 auto-save-timeout 300
 backup-by-copying t
 backup-directory-alist '(("." . "~/.emacs.d/backups"))
 blink-cursor-mode t
 column-number-mode t
 comint-input-ignoredups t
 comint-input-ring-size 1000
 comint-move-point-for-output t
 comint-process-echoes t
 comint-prompt-read-only nil
 comint-scroll-to-bottom-on-input t
 comint-scroll-to-bottom-on-output t
 comint-scroll-show-maximum-output t
 comint-use-prompt-regexp nil
 create-lockfiles nil
 cua-auto-tabify-rectangles nil
 cua-keep-region-after-copy t
 delete-old-versions t
 elpy-rpc-virtualenv-path "venv"
 fast-but-imprecise-scrolling t
 fill-column 100
 font-lock-maximum-decoration t
 gc-cons-threshold (* (* 1024 1024) 200)
 global-auto-revert-non-file-buffers t
 indent-tabs-mode nil
 inferior-R-args "--no-restore-history --no-save "
 inhibit-startup-screen t
 make-backup-files t
 mode-require-final-newline nil
 mouse-yank-at-point t
 read-process-output-max (* (* 1024 1024) 3) ;; 3 Mb
 save-abbrevs 'silently
 scroll-conservatively 101
 scroll-margin 0
 scroll-preserve-screen-position t
 sentence-end-double-space t
 show-paren-delay 0
 show-paren-style 'parenthesis
 time-stamp-format "%3a %3b %2d %02H:%02M:%02S %:y Ashton Trey Belew (abelew@gmail.com)"
 transient-mark-mode t
 use-file-dialog nil
 vc-follow-symlinks t
 vc-make-backup-files t
 version-control t
 select-enable-clipboard t
 select-enable-primary t)

;(set-face-attribute 'default nil :font "Fira Code Retina" :height efs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Ubuntu Mono" :height 180)

;; Set the variable pitch face
(set-face-attribute 'default nil :font "Ubuntu Mono" :height 180)
;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 180)
;; Set the variable pitch face
;;(set-face-attribute 'default nil :font "Fira Code Retina" :height efs/default-font-size)
;; Set the fixed pitch face
;;(set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height efs/default-font-size)
;; Set the variable pitch face
;;(set-face-attribute 'variable-pitch nil :font "Cantarell" :height efs/default-variable-font-size :weight 'regular)
;; Set the fixed pitch face
(global-font-lock-mode 1)
