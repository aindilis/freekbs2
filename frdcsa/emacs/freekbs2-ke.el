(global-set-key "\C-csk" 'freekbs2-knowledge-editor)
(global-set-key "\C-csK" 'freekbs2-knowledge-editor-commit)
(global-set-key "\C-csD" 'freekbs2-knowledge-editor-commit-differential)

(add-to-list 'auto-mode-alist '("\\.kbs\\'" . freekbs2-knowledge-editor-mode))

(defvar freekbs2-knowledge-editor-buffer-local-context nil)
(make-variable-buffer-local 'freekbs2-knowledge-editor-buffer-local-context)
(defvar freekbs2-knowledge-editor-buffer-local-pretty-print nil)
(make-variable-buffer-local 'freekbs2-knowledge-editor-buffer-local-pretty-print)
(defvar freekbs2-knowledge-editor-buffer-local-command nil)
(make-variable-buffer-local 'freekbs2-knowledge-editor-buffer-local-command)

(define-derived-mode freekbs2-knowledge-editor-mode
 emacs-lisp-mode "KBS2-KE"
 "Major mode for rapid manipulation of symbolic knowledge.
\\{freekbs2-knowledge-editor-mode-map}"
 (setq case-fold-search nil)
 (define-key freekbs2-knowledge-editor-mode-map "\C-c\C-c" 'freekbs2-knowledge-editor-toggle-insert)
 (define-key freekbs2-knowledge-editor-mode-map "a" 'freekbs2-knowledge-editor-assert)
 (define-key freekbs2-knowledge-editor-mode-map "u" 'freekbs2-knowledge-editor-unassert)
 (define-key freekbs2-knowledge-editor-mode-map "n" 'freekbs2-knowledge-editor-next-formula)
 (define-key freekbs2-knowledge-editor-mode-map "p" 'freekbs2-knowledge-editor-previous-formula)
 (define-key freekbs2-knowledge-editor-mode-map "l" 'freekbs2-load-assertion-into-stack)
 (define-key freekbs2-knowledge-editor-mode-map "K" 'freekbs2-knowledge-editor-commit)
 (define-key freekbs2-knowledge-editor-mode-map "x" 'freekbs2-knowledge-editor-select-context)
 (define-key freekbs2-knowledge-editor-mode-map "C" 'freekbs2-knowledge-editor-view-context)
 (define-key freekbs2-knowledge-editor-mode-map "q" 'quit-window)
 (define-key freekbs2-knowledge-editor-mode-map "e" 'freekbs2-knowledge-editor-edit-assertion)
 (define-key freekbs2-knowledge-editor-mode-map "P" 'freekbs2-knowledge-editor-toggle-pretty-print)
 (define-key freekbs2-knowledge-editor-mode-map "X" 'freekbs2-knowledge-editor-export-context)
 (define-key freekbs2-knowledge-editor-mode-map "e" 'freekbs2-knowledge-editor-edit-context)
 (suppress-keymap freekbs2-knowledge-editor-mode-map)
 (make-variable-buffer-local 'freekbs2-knowledge-editor-buffer-local-context))

(define-derived-mode freekbs2-knowledge-editor-insert-mode
 emacs-lisp-mode "KBS2-KE-insert"
 "Major mode for rapid manipulation of symbolic knowledge.
\\{freekbs2-knowledge-editor-mode-map}"
 (setq case-fold-search nil)
 (define-key freekbs2-knowledge-editor-insert-mode-map "\C-c\C-c" 'freekbs2-knowledge-editor-toggle-insert)
 (define-key freekbs2-knowledge-editor-insert-mode-map "\C-e" 'freekbs2-knowledge-editor-lock-context)

 (setq freekbs2-knowledge-editor-buffer-local-pretty-print nil)
 (make-variable-buffer-local 'freekbs2-knowledge-editor-buffer-local-context))

(defun freekbs2-knowledge-editor-edit-context ()
 "toggle between KBS2-KE and KBS2-KE-insert modes"
 (interactive)
 (let ((context freekbs2-knowledge-editor-buffer-local-context))
  (see context)
  (if (derived-mode-p 'freekbs2-knowledge-editor-mode)
   (progn
    (freekbs2-knowledge-editor-insert-mode)
    (setq freekbs2-knowledge-editor-buffer-local-context context)))))

(defun freekbs2-knowledge-editor-lock-context ()
 "toggle between KBS2-KE and KBS2-KE-insert modes"
 (interactive)
 (let ((context freekbs2-knowledge-editor-buffer-local-context))
  (see context)
  (if (derived-mode-p 'freekbs2-knowledge-editor-insert-mode)
   (progn
    (freekbs2-knowledge-editor-mode)
    (setq freekbs2-knowledge-editor-buffer-local-context context)))))

(defun freekbs2-knowledge-editor-toggle-insert ()
 "toggle between KBS2-KE and KBS2-KE-insert modes"
 (interactive)
 (if (derived-mode-p 'freekbs2-knowledge-editor-mode)
  (freekbs2-knowledge-editor-insert-mode)
  (if (derived-mode-p 'freekbs2-knowledge-editor-insert-mode)
   (freekbs2-knowledge-editor-mode))))

(defun freekbs2-knowledge-editor (&optional my-context my-buffer my-command)
 ""
 (interactive)
 (let* ((context (if my-context my-context freekbs2-context))
	(buffer (if my-buffer my-buffer 
		 (get-buffer-create
		  (freekbs2-get-buffername-for-context context))))
	(command (if my-command my-command 
		  (concat 
		   "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c "
		   (shell-quote-argument context)
		   " show 2> /dev/null"))))
  (pop-to-buffer buffer)
  (erase-buffer)
  ;; (see command)
  (insert 
   (freekbs2-convert-perl-quoted-emacs-to-emacs-quoted-emacs
    (shell-command-to-string command)))
  (setq freekbs2-knowledge-editor-buffer-local-pretty-print nil)
  (beginning-of-buffer)
  (freekbs2-knowledge-editor-mode)

  (setq freekbs2-knowledge-editor-buffer-local-pretty-print nil)
  (setq freekbs2-knowledge-editor-buffer-local-context context)
  (setq freekbs2-knowledge-editor-buffer-local-command command)
  ))

(defun freekbs2-convert-perl-quoted-emacs-to-emacs-quoted-emacs (perl-quoted-emacs)
 (concat (join "\n"
	  (mapcar (lambda (item) (prin1-to-string item))
	   (read (concat "(" perl-quoted-emacs ")"))))
  "\n"))

(defun freekbs2-get-buffername-for-context (context)
 ""
 (concat "all-asserted-knowledge for context " context))

(defun freekbs2-knowledge-editor-commit ()
 ""
 (interactive)
 ;; make sure the current window is a knowledge editor window
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 ;; grab the correct context from the buffer-local variable
 (if (string= 
      (freekbs2-get-buffername-for-context freekbs2-knowledge-editor-buffer-local-context)
      (buffer-name))
  ;; write the file then execute
  (if
   (yes-or-no-p
    (concat "Clear the context <" freekbs2-knowledge-editor-buffer-local-context ">? "))
   (let ((tmpfile "/tmp/freekbs2.kbs"))
    (write-file tmpfile)
    (shell-command-in-new-buffer-interactive
     (concat
      "kbs2 -y -c " 
      (shell-quote-argument freekbs2-knowledge-editor-buffer-local-context)
      " fast-import "  (shell-quote-argument tmpfile)))))
  (error "Buffer name does not match")))

(defun freekbs2-knowledge-editor-commit-differential ()
 ""
 (interactive)
 ;; make sure the current window is a knowledge editor window
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 ;; sort the buffer, sort the domain, do a diff, figure out which
 ;; assertions must be removed, and which added, then do those

 (if (string= 
      (freekbs2-get-buffername-for-context freekbs2-knowledge-editor-buffer-local-context)
      (buffer-name))
  (if
   (yes-or-no-p
    (concat "Clear the context <" freekbs2-knowledge-editor-buffer-local-context ">? "))
   (let ((tmpfile1 "/tmp/freekbs2-1.kbs")
	 (tmpfile2 "/tmp/freekbs2-2.kbs")
	 (tmpfile3 "/tmp/freekbs2-3.kbs")
	 (tmpfile4 "/tmp/freekbs2-4.kbs"))
    (write-file tmpfile1)
    (shell-command
     (concat "cat " (shell-quote-argument tmpfile1) " | sort -u > " (shell-quote-argument tmpfile2)))
    (kmax-write-string-to-file
     (freekbs2-get-contents-of-context freekbs2-knowledge-editor-buffer-local-context)
     tmpfile3)
    (shell-command
     (concat "cat " (shell-quote-argument tmpfile3) " | sort -u > " (shell-quote-argument tmpfile4)))
    (let* ((assert
	    (shell-command-to-string (concat "diff " (shell-quote-argument tmpfile2) " " (shell-quote-argument tmpfile4) " | grep -E '^<' | sed -e 's/^< //'")))
	   (unassert 
	    (shell-quote-argument (concat "diff " (shell-quote-argument tmpfile2) " " (shell-quote-argument tmpfile4) " | grep -E '^>' | sed -e 's/^> //'"))))
     (see unassert)
     (see assert)
     )))))

(defun freekbs2-get-contents-of-context (context)
 ""
 (interactive)
 (freekbs2-convert-perl-quoted-emacs-to-emacs-quoted-emacs
  (shell-command-to-string
   (concat 
    "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/kbs2 -c "
    (shell-quote-argument context)
    " show 2> /dev/null"))))

;; FIXME: add a lot of kmax-check-mode

(defun freekbs2-knowledge-editor-next-formula ()
 ""
 (interactive)
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 (condition-case nil
  (progn
   (forward-sexp 2)
   (backward-sexp))
  (error
   (message "Last formula"))))


(defun freekbs2-knowledge-editor-previous-formula ()
 ""
 (interactive)
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 (condition-case nil
  (backward-sexp)
  (error
   (message "First formula"))))

(defun freekbs2-knowledge-editor-select-context ()
 ""
 (interactive)
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
;; (freekbs2-select-context)
 (freekbs2-knowledge-editor))

(defun freekbs2-knowledge-editor-edit-assertion ()
 ""
 (interactive)
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 (freekbs2-load-assertion-into-stack)
 (freekbs2-stack-editor))

(defun freekbs2-knowledge-editor-toggle-pretty-print ()
 ""
 (interactive)
 ;; assume it is in regular mode, switch to pretty print
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 (if freekbs2-knowledge-editor-buffer-local-pretty-print 
  (save-excursion
   (freekbs2-knowledge-editor)
   (setq freekbs2-knowledge-editor-buffer-local-pretty-print nil))
  (save-excursion
   (beginning-of-buffer)
   (insert "(list ")
   (end-of-buffer)
   (insert ")")
   (pp-buffer)
   (freekbs2-knowledge-editor-finish-pretty-print)
   )))

(defun freekbs2-knowledge-editor-finish-pretty-print ()
 ""
 (beginning-of-buffer)
 (delete-char 7)
 (end-of-buffer)
 (delete-char -3)
 (mark-whole-buffer)
 (indent-region (point) (mark))
 (setq freekbs2-knowledge-editor-buffer-local-pretty-print t)
 )

(defun freekbs2-knowledge-editor-assert ()
 "Assert the freekbs2-stack as a formula into the current buffer
local context"
 (interactive) 
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 (let* ((formula freekbs2-stack))
  (if (freekbs2-formula-p formula)
   (if (yes-or-no-p (concat "Assert to context <" freekbs2-knowledge-editor-buffer-local-context "> formula <" (prin1-to-string formula) ">?: "))
    (progn
     (see (freekbs2-assert-formula formula freekbs2-knowledge-editor-buffer-local-context))
     (freekbs2-knowledge-editor-reload)
     ))
   (error "error: freekbs2-stack not a valid freekbs2 formula"))))

(defun freekbs2-knowledge-editor-unassert ()
 "Unassert the sexp-at-point as a formula in the current buffer
local context"
 (interactive)
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 (let* ((formula (car (cdr (read (concat "'" (substring-no-properties (thing-at-point 'sexp))))))))
  (if (freekbs2-formula-p formula)
   (if (yes-or-no-p (concat "Unassert from context <" freekbs2-knowledge-editor-buffer-local-context "> formula <" (prin1-to-string formula) ">?: "))
    (progn
     (see (freekbs2-unassert-formula formula freekbs2-knowledge-editor-buffer-local-context))
     (freekbs2-knowledge-editor-reload)))
   (error "error: sexp-at-point not a valid freekbs2 formula"))))

(defun freekbs2-knowledge-editor-reload ()
 "Reload the current context"
 (kmax-check-mode 'freekbs2-knowledge-editor-mode)
 (freekbs2-knowledge-editor
  freekbs2-knowledge-editor-buffer-local-context
  (current-buffer)
  freekbs2-knowledge-editor-buffer-local-command))

(defun freekbs2-knowledge-editor-view-context ()
 "Display the buffer local context for the KE window"
 (interactive)
 (see freekbs2-knowledge-editor-buffer-local-context))

(defun freekbs2-knowledge-editor-export-context ()
 "Save the Context file"
 (interactive)
 (let ((file-name (org-frdcsa-manager-dialog-file-chooser)))
  (if (y-or-n-p (concat "Export to this file <" file-name ">?: "))
   (write-file file-name))))

(provide 'freekbs2-knowledge-editor)


