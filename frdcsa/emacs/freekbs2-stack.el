(global-set-key "\C-csk" 'freekbs2-stack-editor)
(global-set-key "\C-csK" 'freekbs2-stack-editor-commit)

(define-derived-mode freekbs2-stack-editor-mode
 emacs-lisp-mode "FreeKBS2-Stack-Editor"
 "Major mode for rapid manipulation of symbolic stack.
\\{freekbs2-stack-editor-mode-map}"
 (setq case-fold-search nil)
 ;; (define-key freekbs2-stack-editor-mode-map ">" 'freekbs2-get-id-of-assertion-at-point)
 ;; (define-key freekbs2-stack-editor-mode-map "X" 'freekbs2-select-context)
 ;; (define-key freekbs2-stack-editor-mode-map "C" 'freekbs2-view-context)

 (define-key freekbs2-stack-editor-mode-map "c" 'freekbs2-clear-stack)
 (define-key freekbs2-stack-editor-mode-map "p" 'freekbs2-pop-stack)
 (define-key freekbs2-stack-editor-mode-map "E" 'freekbs2-read-from-minibuffer)

;;  (define-key freekbs2-stack-editor-mode-map "K" 'freekbs2-stack-editor-commit)
;;  (define-key freekbs2-stack-editor-mode-map "x" 'freekbs2-stack-editor-select-context)

 (define-key freekbs2-stack-editor-mode-map "q" 'quit-window)
 (suppress-keymap freekbs2-stack-editor-mode-map)
 )

(defun freekbs2-stack-editor ()
 ""
 (interactive)
 ;; open up a new window which shows the classifications
 (let* ((buffer (get-buffer-create (concat "all-asserted-stack for context " freekbs2-context))))
  (pop-to-buffer buffer)
  (erase-buffer)
  (insert (shell-command-to-string
  	   (concat 
  	    "kbs2 -c "
  	    (shell-quote-argument freekbs2-context)
  	    " show 2> /dev/null")))
  (beginning-of-buffer)
  (freekbs2-stack-editor-mode)))

(defun freekbs2-stack-editor-commit ()
 ""
 (interactive)
 ;; make sure the current window is a stack editor window

 ;; grab the correct context from the buffer-local variable
 
 ;; write the file then execute
 (let ((tmpfile "/tmp/freekbs2.kbs"))
  (write-file tmpfile)
  (shell-command-in-new-buffer-interactive
   (concat
    "kbs2 -c " 
    (shell-quote-argument freekbs2-context)
    " fast-import "  (shell-quote-argument tmpfile)))))

(defun freekbs2-stack-editor-next-formula ()
 ""
 (interactive)
 (condition-case nil
  (progn
   (forward-sexp 2)
   (backward-sexp))
  (error
   (message "Last formula"))))


(defun freekbs2-stack-editor-previous-formula ()
 ""
 (interactive)
 (condition-case nil
  (backward-sexp)
  (error
   (message "First formula"))))

(defun freekbs2-stack-editor-select-context ()
 ""
 (interactive)
 (freekbs2-select-context)
 (freekbs2-stack-editor))

(defun freekbs2-stack-editor-edit-assertion ()
 ""
 (interactive)
 (freekbs2-load-assertion-into-stack)
 (freekbs2-stack-editor))

(provide 'freekbs2-stack-editor)
