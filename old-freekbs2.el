;; freekbs2.el

(global-set-key "\C-csd" 'freekbs2-set-query)

(global-set-key "\C-cs>" 'freekbs2-get-id-of-assertion-at-point)
(global-set-key "\C-csX" 'freekbs2-select-context)
(global-set-key "\C-csC" 'freekbs2-view-context)

(global-set-key "\C-csc" 'freekbs2-clear-stack)
(global-set-key "\C-csv" 'freekbs2-view-stack)
(global-set-key "\C-cse" 'freekbs2-edit-stack)
(global-set-key "\C-csE" 'freekbs2-read-from-minibuffer)
(global-set-key "\C-csp" 'freekbs2-pop-stack)

(global-set-key "\C-cs." 'freekbs2-push-entry-at-point-onto-stack)
(global-set-key "\C-cs," 'freekbs2-push-entry-in-region-onto-stack)
(global-set-key "\C-csl" 'freekbs2-load-assertion-into-stack)
(global-set-key "\C-css" 'freekbs2-push-symbol-onto-stack)
(global-set-key "\C-csS" 'freekbs2-es-buffer)
(global-set-key "\C-csw" 'freekbs2-push-region-onto-stack)
(global-set-key "\C-csy" 'freekbs2-push-yank-onto-stack)
(global-set-key "\C-csm" 'freekbs2-push-read-from-minibuffer-onto-stack)
(global-set-key "\C-cst" 'freekbs2-push-tap-onto-stack)
(global-set-key "\C-csn" 'freekbs2-push-variable-onto-stack)

(global-set-key "\C-csP" 'freekbs2-unshift-predicate-onto-stack)
(global-set-key "\C-cs!" 'freekbs2-craft-not-formula)
(global-set-key "\C-csE" 'freekbs2-craft-exists-formula)
(global-set-key "\C-csV" 'freekbs2-craft-forall-formula)

(global-set-key "\C-csA" 'freekbs2-assert-formula)
(global-set-key "\C-csa" 'freekbs2-assert-formula-read-predicate)
(global-set-key "\C-csU" 'freekbs2-unassert-formula)
(global-set-key "\C-csu" 'freekbs2-unassert-formula-read-predicate)
(global-set-key "\C-csQ" 'freekbs2-query-formula)
(global-set-key "\C-csq" 'freekbs2-query-formula-read-predicate)

(global-set-key "\C-csf" 'freekbs2-stack-rotate-forward)
(global-set-key "\C-csb" 'freekbs2-stack-rotate-backward)

(global-set-key "\C-cs^" 'freekbs2-pop-metastack)
(global-set-key "\C-cs(" 'freekbs2-push-metastack)

;; (global-set-key "\C-csr" 'freekbs2-ring stuff)
;; (global-set-key "\C-csx" 'freekbs2-execute-functions-on-stack)

(global-set-key "\C-csk" 'freekbs2-knowledge-editor)

(global-set-key "\C-csM" 'freekbs2-map-function-to-formulae-made-from-entries-in-region)

(setq auto-mode-alist
 (cons '("\\.kif$" . emacs-lisp-mode) auto-mode-alist))

(setq freekbs2-buffer-name "*freekbs2*")
(setq freekbs2-method "MySQL")
(setq freekbs2-database "freekbs2")
(setq freekbs2-context "default")
(setq freekbs2-variable-offset 0)
					;(setq freekbs2-context "test")
(setq freekbs2-stack nil)
(setq freekbs2-tap-types
 '(("symbol" . 1)
   ("list" . 1)
   ("sexp" . 1)
   ("defun" . 1)
   ("filename" . 1)
   ("url" . 1)
   ("word" . 1)
   ("sentence" . 1)
   ("whitespace" . 1)
   ("line" . 1)
   ("page" . 1)
   ))

(defun freekbs2-store ()
 "Return the store"
 (interactive)
 (concat freekbs2-method ":" freekbs2-database ":" freekbs2-context))

(defun freekbs2-update-contexts ()
 "Use the existing contexts to set the current context"
 (interactive)
 (eval
  (read
   (shell-command-to-string
    (concat "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/contexts.pl " freekbs2-database)))))

(defun freekbs2-select-context ()
 ""
 (interactive)
 (freekbs2-update-contexts)
 (setq freekbs2-context (completing-read "Context: " freekbs2-contexts))
 )

(defun freekbs2-view-context ()
 ""
 (interactive)
 (message freekbs2-context))

(defun freekbs2-edit-stack ()
 "edit the stack in the minibuffer"
 (interactive)
 (setq freekbs2-stack
  (car 
   (read-from-string
    (concat "("
     (read-from-minibuffer ""
      (join "\n" (mapcar 'prin1-to-string freekbs2-stack)))
     ")")))))

(defun freekbs2-push-variable-onto-stack (arg)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive "P")
 (let ((sym (make-symbol (concat "var-x" (number-to-string freekbs2-variable-offset)))))
  (freekbs2-push-onto-stack sym arg)
  (setq freekbs2-variable-offset (1+ freekbs2-variable-offset))
  ))

(defun freekbs2-push-region-onto-stack (arg)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive "P")
 (freekbs2-push-onto-stack (buffer-substring-no-properties (point) (mark)) arg)
 )

(defun freekbs2-push-symbol-onto-stack (arg)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive "P")
 (freekbs2-push-onto-stack (substring-no-properties (thing-at-point 'symbol)) arg)
 )

(defun freekbs2-push-yank-onto-stack (arg)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive "P")
 (freekbs2-push-onto-stack (yank) arg)
 )

(defun freekbs2-push-read-from-minibuffer-onto-stack (arg)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive "P")
 (freekbs2-push-onto-stack (read-from-minibuffer "Argument: ") arg)
 )

(defun freekbs2-push-tap-onto-stack (arg)
 "Push the thing at point onto the stack, give a choice of things."
 (interactive "P")
 (freekbs2-push-onto-stack
  (eval
   (car
    (read-from-string
     (concat "(substring-no-properties (thing-at-point '" (completing-read "Type: " freekbs2-tap-types) "))")
     )
    )
   )
  arg
  )
 )

(defun freekbs2-push-object-onto-stack (arg)
 "Push the thing at point onto the stack, give a choice of things."
 (interactive "P")
 )

(defun freekbs2-push-onto-stack (items arg)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive)
 (if arg
  (add-to-list 'freekbs2-stack items 1 (lambda (a b) nil)) ;somebody please fix this retarded way of doing unshift
  (push items freekbs2-stack))
 (freekbs2-view-stack)
 )

(defun freekbs2-pop-stack (arg)
 "Push the goal at point onto a list of goals for use in the RPN system"
 (interactive "P")
 (if arg
  (setq freekbs2-stack (reverse (cdr (reverse freekbs2-stack))))
  (pop freekbs2-stack))
 (freekbs2-view-stack)
 )

(defun freekbs2-print-formula (formula)
 ""
 (prin1-to-string formula)
 )

(defun freekbs2-send-command (command formula)
 "Send a command"
 (interactive)
 (let*
  ((message 
    (uea-query-agent-raw nil "KBS2"
     (freekbs2-util-data-dumper
      (list
       (cons "_DoNotLog" 1)
       (cons "Command" command)
       (cons "Method" freekbs2-method)
       (cons "Database" freekbs2-database)
       (cons "Context" freekbs2-context)
       (cons "FormulaString" (freekbs2-print-formula formula))
       (cons "InputType" "Emacs String")
       (cons "Flags" (list 
		      (cons "Quiet" 1)
		      (cons "OutputType" "CycL String")
		      )
	)
       )
      )
     )
    ))
  (see message)))

