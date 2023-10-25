(defun atb/auto-venv-activate ()
  "Automagically activate a venv if there is a venv directory/symlink in the cwd."
  (interactive)
  (if (file-directory-p "venv")
      (progn
        (pyvenv-activate "venv")
        (venv-initialize-interactive-shells)
        (venv-initialize-eshell)
        (venv--activate-dir "venv")
        (add-to-list 'exec-path "venv")
        (message (concat "Activating the venv: " (pwd))))
    (message "No venv was found in the cwd.")))

(defun atb/dtw ()
  (interactive)
  (save-excursion (delete-trailing-whitespace)))

(defun atb/insert-lambda ()
  (interactive)
  (insert "λ"))
(defun atb/insert-delta ()
  (interactive)
  (insert "λ"))

;; Taken directly from:
;; https://stackoverflow.com/questions/47390469/how-to-invoke-process-python-interrupt-and-keyboard-interrupt-in-emacs
(defun atb/interrupt-python ()
  "Send an interrupt signal to python process"
  (interactive)
  (let ((proc (ignore-errors
                (python-shell-get-process-or-error))))
    (when proc
      (interrupt-process proc))))

(defun atb/search-python ()
  (let ((ipy (executable-find "ipython"))
        (py3 (executable-find "python3"))
        (py (executable-find "python")))
    (message "Using '%s'" ipy)
    (cond ((bound-and-true-p ipy) ipy)
          ((bound-and-true-p py3) py3)
          (t py))))

(defun clear-shell ()
  "Clean out an interactive shell inside emacs to hopefully make it responsive again."
  (interactive)
  (let ((old-max comint-buffer-maximum-size))
    (setq comint-buffer-maximum-size 0)
    (comint-truncate-buffer)
    (setq comint-buffer-maximum-size old-max)))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s seconds with %d gc."
           (format "%.2f" (float-time (time-subtract after-init-time before-init-time)))
           gcs-done))
(add-hook 'emacs-startup-hook #'efs/display-startup-time)

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
    (lsp-headerline-breadcrumb-mode))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
    (visual-line-mode 1))

(defun company-R-objects--prefix ()
  (unless (ess-inside-string-or-comment-p)
    (let ((start (ess-symbol-start)))
      (when start
        (buffer-substring-no-properties start (point))))))

(defun company-R-objects--candidates (arg)
  (let ((proc (ess-get-next-available-process)))
    (when proc
      (with-current-buffer (process-buffer proc)
        (all-completions arg (ess--get-cached-completions arg))))))

(defun company-capf-with-R-objects--check-prefix (prefix)
  (cl-search "$" prefix))

(defun company-capf-with-R-objects (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-R-objects))
    (prefix (company-R-objects--prefix))
    (candidates (if (company-capf-with-R-objects--check-prefix arg)
                    (company-R-objects--candidates arg)
                  (company-capf command arg)))
    (annotation (if (company-capf-with-R-objects--check-prefix arg)
                    "R-object"
                  (company-capf command arg)))
    (kind (if (company-capf-with-R-objects--check-prefix arg)
              'field
            (company-capf command arg)))
        (doc-buffer (company-capf command arg))))

(defun my/add-pipe ()
  "Adds a pipe operator %>% with one space to the left and right"
  (interactive)
  (just-one-space 1)
  (insert "%>%")
    (just-one-space 1))

(defun atb/set-frame-name ()
  "Prompt the user for a window title.  Set the frame's title to that string."
  (interactive)
  (let ((title (read-string "Enter window title: " "emacs (")))
    (if (string-match "\\`emacs ([^)]+\\'" title) ; no trailing close-paren
        (setq title (concat title ")")))
    (set-frame-name title)
    ))

(defun now ()
  "Insert string for the current time formatted like '2:34 PM'."
  (interactive)
  (insert (format-time-string "%D %-I:%M %p")))

(defun save-buffer-if-visiting-file (&optional args)
  "Save the current buffer only if it is visiting a file."
  (interactive)
  (if (and (buffer-file-name) (buffer-modified-p))
      (save-buffer args)))

(defun sfp-page-down ()
  "Move down a page, but leave some space."
  (interactive)
  (setq this-command 'next-line)
  (next-line
   (- (window-text-height)
      next-screen-context-lines)))

(defun sfp-page-up ()
  "Move up a page, but leave some space."
  (interactive)
  (setq this-command 'previous-line)
  (previous-line
   (- (window-text-height)
      next-screen-context-lines)))

(defun license (name)
  "Place the licence: NAME at point as a comment."
  (interactive "sWhat license do you want: \n")
  (let*
      ((gpl-text
        "  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
")
       (bsd-text
        " Permission to use, copy, modify, distribute, and sell this software and its
 documentation for any purpose is hereby granted without fee, provided that
 the above copyright notice appear in all copies and that both that
 copyright notice and this permission notice appear in supporting
 documentation.  No representations are made about the suitability of this
 software for any purpose.  It is provided \"as is\" without express or
 implied warranty.
")
       (mit-text
        "Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
")
       (lgpl-text
        "This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
")
       (artistic-text
        "Preamble

The intent of this document is to state the conditions under which a Package may be copied, such that the Copyright Holder maintains some semblance of artistic control over the development of the package, while giving the users of the package the right to use and distribute the Package in a more-or-less customary fashion, plus the right to make reasonable modifications.

/*****************************
Definitions:

    * \"Package\" refers to the collection of files distributed by the Copyright Holder, and derivatives of that collection of files created through textual modification.
    * \"Standard Version\" refers to such a Package if it has not been modified, or has been modified in accordance with the wishes of the Copyright Holder.
    * \"Copyright Holder\" is whoever is named in the copyright or copyrights for the package.
    * \"You\" is you, if you're thinking about copying or distributing this Package.
    * \"Reasonable copying fee\" is whatever you can justify on the basis of media cost, duplication charges, time of people involved, and so on. (You will not be required to justify it to the Copyright Holder, but only to the computing community at large as a market that must bear the fee.)
    * \"Freely Available\" means that no fee is charged for the item itself, though there may be fees involved in handling the item. It also means that recipients of the item may redistribute it under the same conditions they received it.

1. You may make and give away verbatim copies of the source form of the Standard Version of this Package without restriction, provided that you duplicate all of the original copyright notices and associated disclaimers.

2. You may apply bug fixes, portability fixes and other modifications derived from the Public Domain or from the Copyright Holder. A Package modified in such a way shall still be considered the Standard Version.

3. You may otherwise modify your copy of this Package in any way, provided that you insert a prominent notice in each changed file stating how and when you changed that file, and provided that you do at least ONE of the following:

a) place your modifications in the Public Domain or otherwise make them Freely Available, such as by posting said modifications to Usenet or an equivalent medium, or placing the modifications on a major archive site such as ftp.uu.net, or by allowing the Copyright Holder to include your modifications in the Standard Version of the Package.

b) use the modified Package only within your corporation or organization.

c) rename any non-standard executables so the names do not conflict with standard executables, which must also be provided, and provide a separate manual page for each non-standard executable that clearly documents how it differs from the Standard Version.

d) make other distribution arrangements with the Copyright Holder.

4. You may distribute the programs of this Package in object code or executable form, provided that you do at least ONE of the following:

a) distribute a Standard Version of the executables and library files, together with instructions (in the manual page or equivalent) on where to get the Standard Version.

b) accompany the distribution with the machine-readable source of the Package with your modifications.

c) accompany any non-standard executables with their corresponding Standard Version executables, giving the non-standard executables non-standard names, and clearly documenting the differences in manual pages (or equivalent), together with instructions on where to get the Standard Version.

d) make other distribution arrangements with the Copyright Holder.

5. You may charge a reasonable copying fee for any distribution of this Package. You may charge any fee you choose for support of this Package. You may not charge a fee for this Package itself. However, you may distribute this Package in aggregate with other (possibly commercial) programs as part of a larger (possibly commercial) software distribution provided that you do not advertise this Package as a product of your own.

6. The scripts and library files supplied as input to or produced as output from the programs of this Package do not automatically fall under the copyright of this Package, but belong to whomever generated them, and may be sold commercially, and may be aggregated with this Package.

7. C or perl subroutines supplied by you and linked into this Package shall not be considered part of this Package.

8. The name of the Copyright Holder may not be used to endorse or promote products derived from this software without specific prior written permission.

9. THIS PACKAGE IS PROVIDED \"AS IS\" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

The End
")
       (starting-position (point)))
    (save-excursion
      (cond
       ((equal name "bsd")
        (setq my-license bsd-text))
       ((equal name "gpl")
        (setq my-license gpl-text))
       ((equal name "lgpl")
        (setq my-license lgpl-text))
       ((equal name "mit")
        (setq my-license mit-text))
       ((equal name "artistic")
        (setq my-license artistic-text))
       (t
        (error "I do not know your license: %s" name)))
      (insert-string my-license)
      (comment-region starting-position (+ starting-position (length my-license))))))

(defun bsd ()
  "Insert the bsd license"
  (interactive "*")
  (license "bsd"))

(defun lgpl ()
  "Insert the lgpl"
  (interactive "*")
  (license "lgpl"))

(defun artistic ()
  "Insert the artistic license"
  (interactive "*")
  (license "artistic"))

(defun mit ()
  "Insert the mit license"
  (interactive "*")
  (license "mit"))

(defun gpl ()
  "Insert the gpl"
  (interactive "*")
  (license "gpl"))

;; Taken from a portion of the mastering emacs book which discusses
;; bringing together eldoc and flymake.
(defun mp-flycheck-eldoc
    (callback &rest _ignored)
  "Print flycheck messages at point by calling CALLBACK."
  (when-let ((flycheck-errors (and flycheck-mode
                                   (flycheck-overlay-errors-at (point)))))
    (mapc
     (lambda (err)
       (funcall callback
                (format "%s: %s"
                        (let ((level (flycheck-error-level err)))
                          (pcase level
                            ('info (propertize "I" 'face 'flycheck-error-list-info))
                            ('error (propertize "E" 'face 'flycheck-error-list-error))
                            ('warning (propertize "W" 'face 'flycheck-error-list-warning))
                            (_ level)))
                        (flycheck-error-message err))
       :thing (or (flycheck-error-id err)
                  (flycheck-error-group err))
       :face 'font-local-doc-face))
     flycheck-errors)))

(defun my-flycheck-prefer-eldoc ()
  (add-hook 'eldoc-documentation-functions #'mp-flycheck-eldoc nil t)
  (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
  (setq flycheck-display-errors-function nil)
  (setq flycheck-help-echo-function nil))


(defun atb/rot13 (string)
  "Rot13 a string"
  (rot string 13))

(defun atb/rot (my-str num)
  ;; result has one character concatenated to it for every iteration of mapcar
  (let ((result ""))
    (concat result
            ;; mapcar takes two arguments, a function and sequence, the sequence is
            ;; the list of characters which makes up the given string
            ;; the function in this case is the following anonymous lambda form.
            (mapcar
             (function
              (lambda (char)
                (cond
                 ((and (< char 123) (> char 96))  ;; lowercase characters
                  (if (> char (- 122 num))
                      (int-to-char (- char (- 26 num)))
                    (int-to-char (+ char num))))
                 ((and (< char 91) (> char 64))     ;; uppercase characters
                  (if (> char (- 90 num))
                      (int-to-char (- char (- 26 num)))
                    (int-to-char (+ char num))))
                 (t
                  char))))
             (string-to-list my-str)))))

(defun nb-to-html ()
  "Invoke nbconvert on the current buffer."
  (interactive)
  (save-excursion
    (setq buffer-name (format (buffer-name)))
    (setq filename (replace-regexp-in-string "^.*\\/\\(.*\\.ipynb\\)\\*" "\\1" buffer-name))
    (setq nbconvert-command (format "jupyter-nbconvert %s%s --to html 2>%sconvert2.log 1>&2"
                                    default-directory filename default-directory))
    (start-process-shell-command "nbconvert" "*nbconvert*" nbconvert-command)
    ))

(defun nb-to-pdf ()
  "Invoke nbconvert on the current buffer."
  (interactive)
  (save-excursion
    (setq buffer-name (format (buffer-name)))
    (setq filename (replace-regexp-in-string "^.*\\/\\(.*\\.ipynb\\)\\*" "\\1" buffer-name))
    (setq nbconvert-command (format "jupyter-nbconvert %s%s --to pdf 2>%sconvert2.log 1>&2"
                                    default-directory filename default-directory))
    (start-process-shell-command "nbconvert" "*nbconvert*" nbconvert-command)
    ))

(cl-defun ein:start-notebook (&optional (jupyter-path "/usr/bin/jupyter")
                                        (jupyter-directory default-directory)
                                        (jupyter-server "http://127.0.0.1")
                                        (jupyter-port "8888")
                                        (jupyter-pass "trey"))
  "Start a jupyter notebook, and get ein started with it.
In theory invoking this with no arguments should be sufficient assuming you
previously ran 'jupyter notebook pass' with no password and want to connect
to localhost.
If you wish to do more interesting things, then use the optional arguments above."
  (interactive)
  (ein:jupyter-server-start jupyter-path jupyter-directory "")
  (setq notebook-url (concat jupyter-server ":" jupyter-port))
  (ein:notebooklist-login notebook-url jupyter-pass)
  (ein:notebooklist-open)
  )

(defun atb/send-string (string &optional process)
  "Evaluate STRING in a process."
  (interactive "sshell command: ")
  (let* ((proc (or process (get-buffer-process (py-shell))))
         (buffer (process-buffer proc)))
    (with-current-buffer buffer
      (goto-char (point-max))
      (unless (string-match "\\`" string)
        (comint-send-string proc "\n"))
      (comint-send-string proc string)
      (goto-char (point-max))
      (unless (string-match "\n\\'" string)
        ;; Make sure the text is properly LF-terminated.
        (comint-send-string proc "\n"))
      (when py-debug-p (message "%s" (current-buffer)))
      (goto-char (point-max)))))

(defun atb/insert-arrow (&optional spaces)
  "Insert <- in one keystroke so that I don't have an aneurysm."
  (interactive)
  (if spaces
      (insert " <- ")
    (insert "<-")))

(defun atb/insert-arrow-spaces ()
  (interactive)
  (insert " <- "))

(defun x11-forward ()
  (interactive "*")
  (setq dis
        (car (with-temp-buffer
               (insert-file-contents "/home/trey/.displays/last")
               (split-string (buffer-string) "\n" t))))
  (setenv "DISPLAY" dis)
  (setenv "XAUTHORITY" "/home/trey/.Xauthority"))

(defun dos2unix ()
  "Not exactly but it's easier to remember"
  (interactive)
  (set-buffer-file-coding-system 'unix 't))

(defun indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (indent-region (region-beginning) (region-end))
          (message "Indented selected region."))
      (progn
        (indent-buffer)
        (message "Indented buffer.")))))

(defun lc/csv-align-visible (&optional arg)
  "Align visible fields"
  (interactive "P")
  (csv-align-fields nil (window-start) (window-end)))

(defun lc/set-csv-semicolon-separator ()
  (interactive)
  (customize-set-variable 'csv-separators '(";")))

(defun lc/reset-csv-separators ()
  (interactive)
  (customize-set-variable 'csv-separators lc/default-csv-separators))

(defun lc/init-csv-mode ()
  (interactive)
  (lc/set-csv-separators)
  (lc/csv-highlight)
  (call-interactively 'csv-align-fields))

(defun lc/set-csv-separators ()
  (interactive)
  (let* ((n-commas (count-matches "," (point-at-bol) (point-at-eol)))
         (n-semicolons (count-matches ";" (point-at-bol) (point-at-eol))))
    (if ( ; <
         > n-commas n-semicolons)
        (customize-set-variable 'csv-separators '("," " "))
      (customize-set-variable 'csv-separators '(";" " ")))))

;;(defun lc/csv-highlight ()
;;  (interactive)
;;  (font-lock-mode 1)
;;  (let* ((separator (string-to-char (car csv-separators)))
;;         (n (count-matches (string separator) (point-at-bol) (point-at-eol)))
;;         (colors (loop for i from 0 to 1.0 by (/ 2.0 n)
;;                         collect (apply #'color-rgb-to-hex
;;                                        (color-hsl-to-rgb i 0.3 0.5)))))
;;    (loop for i from 2 to n by 2
;;          for c in colors
;;          for r = (format "^\\([^%c\n]+%c\\)\\{%d\\}" separator separator i)
;;          do (font-lock-add-keywords nil `((,r (1 '(face (:foreground ,c))))))))

(defun lc/rename-current-file ()
  "Rename the current visiting file and switch buffer focus to it."
  (interactive)
  (let ((new-filename (lc/expand-filename-prompt
                       (format "Rename %s to: " (file-name-nondirectory (buffer-file-name))))))
    (if (null (file-writable-p new-filename))
        (user-error "New file not writable: %s" new-filename))
    (rename-file (buffer-file-name) new-filename 1)
    (find-alternate-file new-filename)
    (message "Renamed to and now visiting: %s" (abbreviate-file-name new-filename))))

(defun lc/expand-filename-prompt (prompt)
  "Return expanded filename prompt."
  (expand-file-name (read-file-name prompt)))

(cl-defun render-buffer-name (&optional proc-name)
  (interactive)
  (format "*Render:%s*" (buffer-name)))
(defun render-readthedown ()
  (interactive)
  (render-rmd "rmdformats::readthedown"))
(defun render-bioc ()
  (interactive)
  (render-rmd "BiocStyle::html_document"))
(defun render-html ()
  (interactive)
  (render-rmd "html_document"))
(defun render-pdf ()
  (interactive)
  (render-rmd "pdf_document"))
(defun render-doc ()
  (interactive)
  (render-rmd "word_document"))
(defun render-all ()
  (interactive)
  (render-rmd "all"))
;; I want to change this to always use a fresh R process.
(cl-defun render-rmd (&optional (doc-format "html_document"))
  (interactive)
  (save-excursion
    (setq script-buffer (format (buffer-name)))
    (setq ess-gen-proc-buffer-name-function 'render-buffer-name)
    (setq my-rendering-buffer (render-buffer-name))
    (setq script-file-name (buffer-file-name))
    (R)
    (switch-to-buffer-other-window my-rendering-buffer)
    (goto-char (buffer-end 1))
    (setq render-command (format "hpgltools:::renderme('%s', '%s')" script-file-name doc-format))
    (insert render-command)
    (comint-send-input)
    (switch-to-buffer-other-window script-buffer)))

(defun insert-rmd-file-version ()
  (interactive)
  (save-excursion
    (setq script-file-name (ff-basename (buffer-file-name)))
    ;; get rid of extra _vXXXXXXXX strings if they are there.
    (setq script-file-name (replace-regexp-in-string
                            "_v[[:digit:]]+\.Rmd" "\.Rmd" script-file-name))
    ;; Drop the terminal .Rmd
    (setq script-file-name (replace-regexp-in-string
                            "\.Rmd" "" script-file-name))
    (setq version-string (format-time-string "%Y%m%d"))
    (setq insertion-string
          (format "ver <- \"%s\"
  previous_file <- paste0(\"_v\", ver, \".Rmd\")

  tmp <- try(sm(loadme(filename=gsub(pattern=\"\\\\.Rmd\", replace=\"\\\\.rda\\\\.xz\", x=previous_file))))
  rmd_file <- paste0(\"%s_v\", ver, \".Rmd\")
  savefile <- gsub(pattern=\"\\\\.Rmd\", replace=\"\\\\.rda\\\\.xz\", x=rmd_file)
" version-string script-file-name))
    (insert insertion-string)))

(defun insert-rmd-suffix ()
  (interactive)
  (save-excursion
    (setq insertion-string "
```{r saveme}
if (isTRUE(get0(\"skip_load\"))) {
  pander::pander(sessionInfo())
  message(paste0(\"This is hpgltools commit: \", get_git_commit()))
  message(paste0(\"Saving to \", savefile))
  tmp <- sm(saveme(filename=savefile))
}
```")
    (goto-char (point-max))
    (insert insertion-string)))

(defun render-rmd-pdf ()
  (interactive)
  (save-excursion
    (render-rmd "pdf")))

(defun reset-shell()
  (interactive)
  (clear-shell))

(defun shell-bottom ()
  (interactive)
  (end-of-buffer)
  (comint-send-input))

(defun shell-get-process ()
  (if (get-buffer "*shell*")
      nil
    (shell))
  (get-buffer-process "*shell*"))

(defun copy-to-clipboard ()
  "Copies selection to x-clipboard."
  (interactive)
  (if (display-graphic-p)
      (progn
        (message "Yanked region to x-clipboard!")
        (call-interactively 'clipboard-kill-ring-save)
        )
    (if (region-active-p)
        (progn
          (shell-command-on-region (region-beginning) (region-end) "xsel -i -b")
          (message "Yanked region to clipboard!")
          (deactivate-mark))
      (message "No region active; can't yank to clipboard!"))))

(defun paste-from-clipboard ()
  "Pastes from x-clipboard."
  (interactive)
  (if (display-graphic-p)
      (progn
        (clipboard-yank)
        (message "graphics active")
        )
    (insert (shell-command-to-string "xsel -o -b"))))

(defun atb/ess-eval ()
  (interactive)
  (setq ess-r-evaluation-env nil)
  (call-interactively 'ess-eval-line-and-step))

(defun atb/ess-start-interpreter ()
  (interactive)
  (setq ess-startup-directory (file-name-directory buffer-file-name))
  (or (assq 'inferior-ess-mode
            (mapcar
             (lambda (buff) (list (buffer-local-value 'major-mode buff)))
             (buffer-list)))
      (progn
        (delete-other-windows)
        (setq w1 (selected-window))
        (setq w1name (buffer-name))
        (setq w2 (split-window w1 nil t))

        (cond ((eq major-mode "julia-mode")
               (progn
                 (julia)
                 (set-window-buffer w2 "*julia*")
                 (set-window-buffer w1 w1name)))
              ((eq major-mode "r-mode")
               (progn
                 (R)
                 (set-window-buffer w2 "*R*")
                 (set-window-buffer w1 w1name)))))))

(defun find-next-unsafe-char (&optional coding-system)
    "Find the next character in the buffer that cannot be encoded by
coding-system. If coding-system is unspecified, default to the coding
system that would be used to save this buffer. With prefix argument,
prompt the user for a coding system."
    (interactive "Zcoding-system: ")
    (if (stringp coding-system) (setq coding-system (intern coding-system)))
    (if coding-system nil
      (setq coding-system
            (or save-buffer-coding-system buffer-file-coding-system)))
    (let ((found nil) (char nil) (csets nil) (safe nil))
      (setq safe (coding-system-get coding-system 'safe-chars))
      ;; some systems merely specify the charsets as ones they can encode:
      (setq csets (coding-system-get coding-system 'safe-charsets))
      (save-excursion
        ;;(message "zoom to <")
        (let ((end  (point-max))
              (here (point    ))
              (char  nil))
          (while (and (< here end) (not found))
            (setq char (char-after here))
            (if (or (eq safe t)
                    (< char ?\177)
                    (and safe  (aref safe char))
                    (and csets (memq (char-charset char) csets)))
                nil ;; safe char, noop
              (setq found (cons here char)))
            (setq here (1+ here))) ))
      (and found (goto-char (1+ (car found))))
      found))

(defun atb/eir-eval-in-python ()
  "eval-in-repl for Python."
  (interactive)
  ;; Define local variables
  (save-excursion (let* (;; Save current point
         (initial-point (point)))
    ;;
    (eir-repl-start "*Python*" #'eir-run-python)

    ;; Check if selection is present
    (if (and transient-mark-mode mark-active)
        ;; If selected, send region
        (if eir-use-python-shell-send-string
            ;; Use the python-mode function.
            (progn
              (eir-python-shell-send-string (buffer-substring-no-properties (point) (mark)))
              ;; Deactivate selection explicitly (necessary in Emacs 25)
              (deactivate-mark))
          ;; Otherwise, use the copy and paste approach.
          (eir-send-to-python (buffer-substring-no-properties (point) (mark))))

      ;; If not selected, do all the following
      ;; Move to the beginning of line
      (beginning-of-line)
      ;; Set mark at current position
      (set-mark (point))
      ;; Go to the end of statment
      (atb/python-nav-end-of-statement)
      ;; Go to the end of block
      (python-nav-end-of-block)
      ;; Send region if not empty
      (if (not (equal (point) (mark)))
          (if eir-use-python-shell-send-string
              ;; Use the python-mode function.
              (progn
                (eir-python-shell-send-string (buffer-substring-no-properties
                                               (min (+ 1 (point)) (point-max))
                                               (mark)))
                ;; Deactivate selection explicitly (necessary in Emacs 25)
                (deactivate-mark))
            ;; Otherwise, use the copy and paste approach.
            ;; Add one more character for newline unless at EOF
            ;; This does not work if the statement asks for an input.
            (eir-send-to-python (buffer-substring-no-properties
                                 (min (+ 1 (point)) (point-max))
                                 (mark))))
        ;; If empty, deselect region
        (message "About to deactivate mark.")
        (deactivate-mark t)
        (message "Mark deactivated")
        )
      (message "Outside the if")

      ;; Move to the next statement code if jumping
      (if eir-jump-after-eval
          (atb/python-nav-forward-statement)
        ;; Go back to the initial position otherwise
        (goto-char initial-point))))))

(defun atb/python-nav-forward-statement (&optional arg)
  "Move forward to next statement.
With ARG, repeat.  With negative argument, move ARG times
backward to previous statement."
  (interactive "^p")
  (or arg (setq arg 1))
  (while (> arg 0)
    (atb/python-nav-end-of-statement)
    (python-util-forward-comment)
    (python-nav-beginning-of-statement)
    (setq arg (1- arg)))
  (while (< arg 0)
    (python-nav-beginning-of-statement)
    (python-util-forward-comment -1)
    (python-nav-beginning-of-statement)
    (setq arg (1+ arg))))

(defun atb/python-nav-end-of-statement (&optional noend)
  "Move to end of current statement.
Optional argument NOEND is internal and makes the logic to not
jump to the end of line when moving forward searching for the end
of the statement."
  (interactive "^")
  (setq num_errs 0)
  (let (string-start bs-pos (last-string-end 0))
    (catch 'weirdo
    (while (and (or noend (goto-char (line-end-position)))
                (not (eobp))
                (cond ((setq string-start (python-syntax-context 'string))
                       ;; The condition can be nil if syntax table
                       ;; text properties and the `syntax-ppss' cache
                       ;; are somehow out of whack.  This has been
                       ;; observed when using `syntax-ppss' during
                       ;; narrowing.
                       ;; It can also fail in cases where the buffer is in
                       ;; the process of being modified, e.g. when creating
                       ;; a string with `electric-pair-mode' disabled such
                       ;; that there can be an unmatched single quote
                       (when (>= string-start last-string-end)
                         (goto-char string-start)
                         (if (python-syntax-context 'paren)
                             ;; Ended up inside a paren, roll again.
                             (python-nav-end-of-statement t)
                           ;; This is not inside a paren, move to the
                           ;; end of this string.
                           (goto-char (+ (point)
                                         (python-syntax-count-quotes
                                          (char-after (point)) (point))))
                           (setq last-string-end
                                 (or (re-search-forward
                                      (rx (syntax string-delimiter)) nil t)
                                     (goto-char (point-max)))))))
                      ((python-syntax-context 'paren)
                       ;; The statement won't end before we've escaped
                       ;; at least one level of parenthesis.
                       ;;(condition-case err
                       ;;    (goto-char (scan-lists (point) 1 -1))
                       ;;  (scan-error (goto-char (nth 3 err)))))
                       (condition-case err
                           (progn (goto-char (point))
                                  (throw 'weirdo (point))))
                         (scan-error (goto-char string-start))))
                      ((setq bs-pos (python-info-line-ends-backslash-p))
                       (goto-char bs-pos)
                       (forward-line 1))))))
  (point-marker))

(defun atb/org-send ()
  (interactive)
  (let ((info (org-babel-get-src-block-info)))
    (cond ((eq "scheme" (first info))
           (eir-eval-in-geiser)))))
