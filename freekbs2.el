;; freekbs2.el

;; (require 'ert)

(defvar freekbs2-verbose t "")

(global-set-key "\C-csd" 'freekbs2-set-query)

(global-set-key "\C-cs>" 'freekbs2-get-id-of-assertion-at-point)
(global-set-key "\C-csX" 'freekbs2-select-context)
(global-set-key "\C-csC" 'freekbs2-view-context)
(global-set-key "\C-csh" 'freekbs2-isearch-forward-for-tos)

;; for text editing
(global-set-key "\C-cs." 'freekbs2-push-entry-at-point-onto-stack)
(global-set-key "\C-cs," 'freekbs2-push-entry-in-region-onto-stack)

;; for knowledge editor

(global-set-key "\C-csl" 'freekbs2-load-assertion-into-stack-importexport)
(global-set-key "\C-csL" 'freekbs2-load-assertion-into-stack)


;; for stack editor
(global-set-key "\C-csc" 'freekbs2-clear-stack)
(global-set-key "\C-csv" 'freekbs2-view-stack)
(global-set-key "\C-cse" 'freekbs2-edit-stack)
(global-set-key "\C-csp" 'freekbs2-pop-stack)
(global-set-key "\C-csE" 'freekbs2-read-from-minibuffer)


(global-set-key "\C-cccs" 'freekbs2-push-symbol-onto-stack)
(global-set-key "\C-csS" 'freekbs2-es-buffer)
(global-set-key "\C-csw" 'freekbs2-push-region-onto-stack)
(global-set-key "\C-csy" 'freekbs2-push-yank-onto-stack)
(global-set-key "\C-csm" 'freekbs2-push-read-from-minibuffer-onto-stack)
(global-set-key "\C-cs_" 'freekbs2-push-direct-object-onto-stack)
(global-set-key "\C-cstt" 'freekbs2-push-most-interesting-tag-at-point-onto-stack)
(global-set-key "\C-cstd" 'freekbs2-push-tap-onto-stack-defun)
(global-set-key "\C-cstf" 'freekbs2-push-tap-onto-stack-filename)
(global-set-key "\C-cstlin" 'freekbs2-push-tap-onto-stack-line)
(global-set-key "\C-cstiis" 'freekbs2-push-tap-onto-stack-list)
(global-set-key "\C-cstp" 'freekbs2-push-tap-onto-stack-page)
(global-set-key "\C-cstsen" 'freekbs2-push-tap-onto-stack-sentence)
(global-set-key "\C-cstsex" 'freekbs2-push-tap-onto-stack-sexp)
(global-set-key "\C-cstsy" 'freekbs2-push-tap-onto-stack-symbol)
(global-set-key "\C-cstu" 'freekbs2-push-tap-onto-stack-url)
(global-set-key "\C-cstwh" 'freekbs2-push-tap-onto-stack-whitespace)
(global-set-key "\C-cstwo" 'freekbs2-push-tap-onto-stack-word)
(global-set-key "\C-csT" 'freekbs2-push-tap-onto-stack)
(global-set-key "\C-csn" 'freekbs2-push-variable-onto-stack)
(global-set-key "\C-csi" 'freekbs2-insert-top-of-stack)
(global-set-key "\C-csgc" 'freekbs2-push-kmax-w3m-get-a-url-onto-stack)

(global-set-key "\C-csP" 'freekbs2-unshift-predicate-onto-stack)
(global-set-key "\C-cs!" 'freekbs2-craft-not-formula)
(global-set-key "\C-csE" 'freekbs2-craft-exists-formula)
(global-set-key "\C-csV" 'freekbs2-craft-forall-formula)
(global-set-key "\C-cs[]" 'freekbs2-craft-necessary-formula)
(global-set-key "\C-cs<>" 'freekbs2-craft-possible-formula)

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

(global-set-key "\C-cs  " 'freekbs2-condense-whitespace-of-tos)
(global-set-key "\C-cs s" 'freekbs2-santize-for-freekbs2-the-tos)
(global-set-key "\C-cs \"" 'freekbs2-shell-quote-tos)

;; (global-set-key "\C-csr" 'freekbs2-ring stuff)
;; (global-set-key "\C-csx" 'freekbs2-execute-functions-on-stack)

(global-set-key "\C-csM" 'freekbs2-map-function-to-formulae-made-from-entries-in-region)

;; (setq auto-mode-alist
;;  (cons '("\\.kif$" . emacs-lisp-mode) auto-mode-alist))
;; (setq auto-mode-alist
;;  (cons '("\\.kbs$" . emacs-lisp-mode) auto-mode-alist))

(defvar freekbs2-buffer-name "*freekbs2*")
(defvar freekbs2-method "MySQL")
(defvar freekbs2-database "freekbs2")
(defvar freekbs2-context "default")
(defvar freekbs2-variable-offset 0)
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

(defun freekbs2-select-context (arg)
 ""
 (interactive "P")
 (freekbs2-update-contexts)
 (setq freekbs2-context (completing-read "Context: " freekbs2-contexts nil nil (if arg (substring-no-properties (thing-at-point 'filename))))))

(defun freekbs2-view-context ()
 ""
 (interactive)
 (message freekbs2-context))

;; FIXME: replace with a formula edit mode with all kinds of custom
;; keybindings, which has different minor modes for different logics,
;; woohoo!

(defun freekbs2-edit-stack ()
 "edit the stack in the minibuffer"
 (interactive)
 (setq freekbs2-stack
  (car 
   (read-from-string
    (concat "("
     (read-from-minibuffer ""
      (join "\n" (mapcar 'prin1-to-string freekbs2-stack)))
     ")"))))
 (freekbs2-view-ring))

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
  arg))

(defun freekbs2-push-tap-onto-stack-defun (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'defun))")))) arg))

(defun freekbs2-push-tap-onto-stack-filename (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'filename))")))) arg))

(defun freekbs2-push-tap-onto-stack-line (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'line))")))) arg))

(defun freekbs2-push-tap-onto-stack-list (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'list))")))) arg))

(defun freekbs2-push-tap-onto-stack-page (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'page))")))) arg))

(defun freekbs2-push-tap-onto-stack-sentence (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'sentence))")))) arg))

(defun freekbs2-push-tap-onto-stack-sexp (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'sexp))")))) arg))

(defun freekbs2-push-tap-onto-stack-symbol (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'symbol))")))) arg))

(defun freekbs2-push-tap-onto-stack-url (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'url))")))) arg))

(defun freekbs2-push-tap-onto-stack-whitespace (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'whitespace))")))) arg))

(defun freekbs2-push-tap-onto-stack-word (arg)
 "Push the thing at point onto stack"
 (interactive "P")
 (freekbs2-push-onto-stack (eval (car (read-from-string (concat "(substring-no-properties (thing-at-point 'word))")))) arg))

(defun freekbs2-push-object-onto-stack (arg)
 "Push the thing at point onto the stack, give a choice of things."
 (interactive "P")
 (kmax-not-yet-implemented))

(defun freekbs2-push-onto-stack (items &optional arg silent)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive)
 (if arg
  (add-to-list 'freekbs2-stack items 1 (lambda (a b) nil)) ;somebody please fix this retarded way of doing unshift
  (push items freekbs2-stack))
 (unless silent (freekbs2-view-stack)))

(defun freekbs2-push-onto-back-of-stack (items)
 "Push the goal at point onto a list of goals for use in the RPN system."
 (interactive)
 (freekbs2-push-onto-stack items t))

(defun freekbs2-pop-stack-original (arg)
 "Pop the freekbs2 stack, for use in the RPN system"
 (interactive "P")
 (if arg
  (setq freekbs2-stack (reverse (cdr (reverse freekbs2-stack))))
  (pop freekbs2-stack))
 (freekbs2-view-stack)
 )

(defun freekbs2-pop-stack-without-viewing (arg)
 "Pop the freekbs2 stack, for use in the RPN system"
 (interactive "P")
 ;; (message (concat "My stack is " freekbs2-stack))
 (let ((popped-value
	(if arg
	 (let ((temp (reverse freekbs2-stack)))
	  (setq freekbs2-stack (reverse (cdr temp)))
	  (car temp))
	 (pop freekbs2-stack))))
  popped-value))

(defun freekbs2-pop-stack (arg)
 "Pop the freekbs2 stack, for use in the RPN system"
 (interactive "P")
 ;; (message (concat "My stack is " freekbs2-stack))
 (let ((popped-value
	(if arg
	 (let ((temp (reverse freekbs2-stack)))
	  (setq freekbs2-stack (reverse (cdr temp)))
	  (car temp))
	 (pop freekbs2-stack))))
 (freekbs2-view-stack)
  popped-value))



;; (defun freekbs2-print-formula (formula)
;;  ""
;;  (freekbs2-util-convert-from-emacs-to-perl-data-structures formula)
;;  ;; (prin1-to-string formula)
;;  )

(defun freekbs2-send-command (command formula &optional context-arg)
 "Send a command"
 (interactive)
 (let*
  ((context (if context-arg context-arg freekbs2-context))
   (message 
    (uea-query-agent-raw nil "KBS2"
     (freekbs2-util-data-dumper
      (list
       (cons "_DoNotLog" 1)
       (cons "Command" command)
       (cons "Method" freekbs2-method)
       (cons "Database" freekbs2-database)
       (cons "Context" context)
       (cons "Formula" formula)
       (cons "InputType" "Interlingua")
       (cons "OutputType" "CycL String")
       (cons "Flags" (list 
		      ;; (cons "Quiet" 1)
		      (cons "OutputType" "CycL String"))
	
	)
       )
      )
     )
    ))
  message))

(defun freekbs2-formula-is-ground (formula)
 ""
 t)

(defun freekbs2-assert-formula (&optional formula context)
 "Apply a function to the stack, checking arity constraints over multiple function definitions"
 (interactive)
 (freekbs2-send-command "assert" (if formula
				 formula
				 freekbs2-stack) context)
 (if (not formula)
  (freekbs2-clear-stack))
 )

(defun freekbs2-unassert-formula (&optional formula context)
 "Apply a function to the stack, checking arity constraints over multiple function definitions"
 (interactive)
 (freekbs2-send-command "unassert" (if formula
				   formula
				   freekbs2-stack) context)
 (if (not formula)
  (freekbs2-clear-stack))
 )

;; (freekbs2-send-command "query" '("completed" ("UniLang-Entry" var-x0)))

;; FIXME: IMPLEMENT stuff here so that we take into account ternary (T,F,unknown).

(defun freekbs2-get-truthvalue-from-details (details)
 ""
 (cdr
  (assoc "TruthValue"
   details)))

(defun freekbs2-get-cycl-from-details (details)
 ""
 (cdr
  (assoc "CycL"
   details)))

(defun freekbs2-get-details-from-result (result)
 ""
 (let* ((answer nil))
  (if (cdr (assoc "CycL" result))
   (push (cons "CycL" (read (cdr (assoc "CycL" result)))) answer)
   (if (or 
	(string= (cdr (assoc "TruthValue" result)) "true")
	(string= (cdr (assoc "TruthValue" (cdr (assoc "Results" result)))) "true")
	(string=
	 (cdr (assoc "Type" 
	       (cdr (assoc "Result"
		     (car (last (cdr (assoc "Results" result)))))))) 
	 "Theorem")
	)
    (push (cons "TruthValue" t) answer)
    (if (string= (cdr (assoc "TruthValue" result)) "false")
     (push (cons "TruthValue" nil) answer))))
  answer)
 )

(defun freekbs2-variables-in-formula (formula)
 "Return the free variables in a given formula"
 (if (listp formula)
  (if (> (length formula) 0)
   (if
    (or
     (freekbs2-variables-in-formula (car formula))
     (freekbs2-variables-in-formula (cdr formula))
     )
    t
    nil)
   nil)
  (if (symbolp formula)
   (freekbs2-symbol-is-freekbs2-variable-p formula))))

(defun freekbs2-query-formula (&optional formula context)
 "Apply a function to the stack, checking arity constraints over multiple function definitions"
 (interactive)
 (let* ((result 
	 (freekbs2-get-result
	  (freekbs2-send-command "query" (if formula
					  formula
					  freekbs2-stack) context))))
  (if (not formula)
   (freekbs2-clear-stack))
  result))

(defun freekbs2-query-formula (&optional formula context)
 "Apply a function to the stack, checking arity constraints over multiple function definitions"
 (interactive)
 (if (freekbs2-variables-in-formula formula)
  (let* ((result 
	  (freekbs2-get-result
	   (freekbs2-send-command "query" (if formula
					   formula
					   freekbs2-stack) context))))
   (if (not formula)
    (freekbs2-clear-stack))
   result)
  ;; presumably process this differently
  (let* ((result 
	  (freekbs2-send-command "query" (if formula
					  formula
					  freekbs2-stack) context)))
   (if (not formula)
    (freekbs2-clear-stack))
   result)))

(defun freekbs2-assert-formula-read-predicate (&optional formula context)
 "Apply a function to the stack, checking arity constraints over multiple function definitions"
 (interactive)
 (freekbs2-assert-formula (if formula
			  formula
			  (freekbs2-get-formula)) context))

(defun freekbs2-unassert-formula-read-predicate (&optional formula context)
 "Apply a function to the stack, checking arity constraints over multiple function definitions"
 (interactive)
 (freekbs2-send-command "unassert" (if formula
				   formula
				   (freekbs2-get-formula)) context)
 (if (not formula)
  (freekbs2-clear-stack))
 )

(defun freekbs2-query-formula-read-predicate (&optional formula context)
 "Apply a function to the stack, checking arity constraints over multiple function definitions"
 (interactive)
 (let* ((result 
	 (freekbs2-get-result
	  (freekbs2-send-command "query" (if formula
					  formula
					  (freekbs2-get-formula)) context))))
  (if (not formula)
   (freekbs2-clear-stack))
  result))

(defun freekbs2-update-predicates ()
 "Using a script, update the predicates"
 (eval
  (read
   (shell-command-to-string
    (concat
     "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/assist.pl "
     (shell-quote-argument freekbs2-database)
     " "
     (shell-quote-argument freekbs2-context))))))

(defun freekbs2-get-predicate ()
 ""
 (freekbs2-update-predicates)
 (let (
       (x (completing-read "Predicate: " freekbs2-predicates))
       )
  (if (string= x "")
   nil
   x)))

(defun freekbs2-get-formula ()
 ""
 (let (
       (x (append (list (freekbs2-get-predicate)) freekbs2-stack))
       )
					; (freekbs2-clear-stack)
  x)
 )

(defun freekbs2-view-stack ()
 ""
 (interactive)
 (if (gnus-buffer-exists-p freebs2-view-ring-buffer-name)
  (freekbs2-view-ring))
 (message (prin1-to-string freekbs2-stack)))

(defun freekbs2-clear-stack (&optional arg)
 ""
 (interactive "P")
 (if (not arg)
  (setq freekbs2-stack nil)
  (setq freekbs2-stack (list (car freekbs2-stack))))
 (freekbs2-view-stack))

(defun freekbs2-undo ()
 "Undo the last critique"
 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; EAP ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun freekbs2-get-result (message)
 ""
 (cdr
  (assoc "Result"
   (freekbs2-util-data-dedumper
    (nth 5 message)))))

(defun freekbs2-uea-query-agent (contents receiver data)
 "get the result from uea"
 (freekbs2-get-result
  (uea-query-agent-raw nil receiver
   (freekbs2-util-data-dumper data))))

;; (defun freekbs2-entry (entry)
;;  "Grab the relation for the entry"
;;  (interactive)
;;  (shell-command-to-string
;;   (concat "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/helper/get-entry.pl --has-nl "
;;    (shell-quote-argument (substring-no-properties entry)))))

(defun freekbs2-entry (entry)
 "Grab the ID for the entry"
 (interactive)
 (let* ((entry-no-properties (substring-no-properties entry))
	(entry-id (shell-command-to-string
		   (concat "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/helper/lookup-entry.pl unilang messages Contents ID "
		    (shell-quote-argument entry-no-properties)))))
  (if (and
       (not (string= entry-id ""))
       (non-nil entry-id))
   (read (concat "(\"unilang-entry-fn\" \"" entry-id "\")"))
   (error "No UniLang entry found for '%s'" (chomp entry-no-properties)))))

;; (defun freekbs2-entry (entry)
;;  "Grab the ID for the entry, by sending to KBS2"
;;  (interactive)
;;  (list "unilang-entry-id-fn" 
;;   (freekbs2-uea-query-agent nil "KBS2"
;;    (list
;;     (cons "_DoNotLog" 1)
;;     (cons "Command" "lookup-entry")
;;     (cons "Database" "unilang")
;;     (cons "Table" "messages")
;;     (cons "Field" "Contents")
;;     (cons "Item" "ID")
;;     (cons "Search" entry)
;;     ))))

;; ("completed" ("UniLang-Entry" var-x0))

(defun freekbs2-load-onto-stack (stack-item)
 ""
 (interactive)
 (let ((item freekbs2-stack))
  (setq freekbs2-stack stack-item)
  (freekbs2-ring-add-result item)))

(defun freekbs2-load-assertion-into-stack ()
 ""
 (interactive)
 (freekbs2-load-onto-stack
  (read (substring-no-properties (thing-at-point 'sexp)))))
 
(defun freekbs2-load-assertion-into-stack-importexport (arg)
 ""
 (interactive "P")
 (if arg
  (freekbs2-load-assertion-into-stack)
  (let ((item freekbs2-stack))
   (setq freekbs2-stack (freekbs2-get-assertion-importexport t "CycL String"))
   (freekbs2-ring-add-result item))))

(defun freekbs2-get-assertion-importexport (arg &optional provided-input-type input-arg)
 "use import export to pull in the assertion at stack, assume
that at least parens are balanced"
 (interactive "P")
 (let* ((input (if input-arg input-arg (substring-no-properties (thing-at-point 'sexp))))
	(input-type
	 (if arg
	  (if (non-nil provided-input-type)
	   provided-input-type
	   (completing-read "Input type?: " '("CycL String" "KIF String" "Emacs String" "Prolog String")))))
	(final-input
	 (if (string= input-type "CycL String")
	  (concat "(#$or " input ")")
	  input))
	(result 
	 (if arg
	  (freekbs2-importexport-convert final-input input-type)
	  (freekbs2-importexport-convert final-input))))
  (see final-input)
  (if (alistp result)
   (if (string= (cdr (assoc "Success" result)) "1")
    (read
     (freekbs2-convert-perl-quoted-emacs-to-emacs-quoted-emacs
      (cdr (assoc "Output" result))))))))

;; (message (freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Command" . "importexport") ("Input" . "(#$purposeInEvent #$UN-SecurityCouncil #$PassingUNSC-Resolution678 
;;   (#$exists 
;;    (?WITHDRAWAL) 
;;    (#$and 
;;     (#$isa ?WITHDRAWAL #$MilitaryWithdrawal) 
;;     (#$performedBy ?WITHDRAWAL 
;;      (#$ArmyFn #$Iraq)) 
;;     (#$toLocation ?WITHDRAWAL #$Iraq) 
;;     (#$fromLocation ?WITHDRAWAL #$Kuwait))))") ("InputType" . "CycL String") ("OutputType" . "Emacs String"))))

(defun freekbs2-importexport-convert (input &optional input-type output-type)
 (interactive)
 (freekbs2-uea-query-agent nil "KBS2"
  (list
   (cons "_DoNotLog" 1)
   (cons "Command" "importexport")
   (cons "Input" input)
   (cons (if input-type "InputType" "GuessInputType") (if input-type input-type 1))
   (cons "OutputType" (if output-type output-type "Emacs String"))))
 )

(defun freekbs2-get-id-of-assertion-at-point ()
 "Grab the ID for the entry"
 (interactive)
 (freekbs2-assertion (thing-at-point 'line)))

(defun freekbs2-get-formula-from-assertion-id (assertion-id)
 ""
 (interactive)
 (read-from-string
  (shell-command-to-string
   (concat "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/lookup-assertion.pl GetFormula "
    assertion-id))))

(defun freekbs2-send (string)
 "Send a command to KBS through UEA"
 (interactive)
 (let
  ((mymessage (concat "KBS, " string)))
  (uea-send-contents mymessage)
  (message mymessage)
  )
 )

;; (defun freekbs2-unassert-assertion-at-point ()
;;  "Grab the ID for the entry"
;;  (interactive)
;;  (let ((assertionid (freekbs2-assertion (thing-at-point 'line))))
;;   (if (numberp assertionid)
;;    (freekbs2-send
;;     (concat "unassert-by-assertion-id " assertionid)))))

(defun freekbs2-unassert-assertion-at-point ()
 "Grab the ID for the entry"
 (interactive)
 (let ((formula
	(freekbs2-get-formula-from-assertion-id
	 (freekbs2-get-id-of-assertion-at-point))))
  (if (length formula)
   (freekbs2-unassert-formula formula))))

;; (defun freekbs2-assertion (entry)
;;  "Grab the ID for the entry"
;;  (interactive)
;;  (message (shell-command-to-string
;;   (concat "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/lookup-assertion.pl GetID "
;;    (shell-quote-argument (substring-no-properties entry))))))

(defun freekbs2-assertion (entry)
 "Grab the ID for the entry"
 (interactive)
 (message (shell-command-to-string
	   (concat "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/lookup-assertion.pl GetID "
	    (shell-quote-argument (substring-no-properties entry))))))

					; (freekbs2-entry "Checkout Life of Hugh Roe O'Donnell from interlibrary loan.")

(defun freekbs2-push-entry-onto-stack (entry arg)
 "Push the entry at point onto a list of goals for use in the RPN system."
 (interactive)
 (freekbs2-push-onto-stack (freekbs2-entry entry) arg))

(defun freekbs2-push-entry-at-point-onto-stack (arg)
 ""
 (interactive "P")
 (freekbs2-push-entry-onto-stack (thing-at-point 'line) arg))

(defun freekbs2-push-entry-in-region-onto-stack (arg)
 ""
 (interactive "P")
 (freekbs2-push-entry-onto-stack (buffer-substring-no-properties (point) (mark)) arg))

;; (defun freekbs2-call-function-on-keybinding-with-stack-as-args ()
;;  "Call the next"
;;  (interactive)
;;  ())

(defun freekbs2-all-assertions-eap ()
 ""
 )

(defun freekbs2-push-completing-read-from-minibuffer-onto-stack ()
 ""
 )

;; (defun freekbs2-list-eap-formulae ())
;; (defun freekbs2-edit-eap-formulae ())

(defun freekbs2-process-message (contents)
 ""
 ;; here is the behaviour, append it to the list, unless it is greater than 
 (if (> (length (split-string contents "\n")) 5)
  (let ((buffer (generate-new-buffer "FreeKBS2 long result")))
   (switch-to-buffer buffer)
   (insert contents)
   (beginning-of-buffer))
  (let ((buffer (get-buffer-create "FreeKBS2 short results")))
   (save-excursion
    (set-buffer buffer)
    (end-of-buffer)
    (insert contents)
    )
   (message contents))
  ))

(defun freekbs2-read-from-minibuffer ()
 ""
 (interactive)
 (setq freekbs2-stack
  (read (read-from-minibuffer "Axiom: ")))
 (freekbs2-view-stack))

;; (defun freekbs2-knowledge-editor ()
;;  "Grab the ID for the entry, by sending to KBS2"
;;  (interactive)
;;  (list "unilang-entry-id-fn" 
;;   (freekbs2-uea-query-agent nil "KBS2"
;;    (list
;;     (cons "_DoNotLog" 1)
;;     (cons "Command" "lookup-entry")
;;     (cons "Database" "unilang")
;;     (cons "Table" "messages")
;;     (cons "Field" "Contents")
;;     (cons "Item" "ID")
;;     (cons "Search" entry)
;;     ))))

(defun freekbs2-get-entry ()
 "Obtain the entry formula for the item at point"
 (interactive)
 (list "unilang-entry-id-fn" 
  (freekbs2-uea-query-agent nil "KBS2"
   (list
    (cons "_DoNotLog" 1)
    (cons "Command" "lookup-entry")
    (cons "Database" "unilang")
    (cons "Table" "messages")
    (cons "Field" "Contents")
    (cons "Item" "ID")
    (cons "Search" entry)
    ))))

;; (defun freekbs2-knowledge-editor ()
;;  ""
;;  (interactive)
;;  ;; open up a new window which shows the classifications
;;  (let* ((item (critic-get-entry))
;; 	(buffer (get-buffer-create (concat "all-asserted-knowledge for context " freekbs2-context))))
;;   (pop-to-buffer buffer)
;;   (erase-buffer)
;;   (insert (shell-command-to-string
;; 	   (concat 
;; 	    "/var/lib/myfrdcsa/codebases/releases/freekbs2-0.2/freekbs2-0.2/scripts/all-asserted-knowledge.pl "
;; 	    freekbs2-context)))
;;   (beginning-of-buffer)
;;   )
;;  )

(defun shell-command-in-new-buffer-interactive (command)
 ""
 (let ((mybuffer
	(get-buffer-create (generate-new-buffer-name "*shell*"))))
  (shell mybuffer)
  (switch-to-buffer mybuffer)
  (sit-for 3)
  (insert command)
  (ignore-errors
   (comint-send-input)) 
  ;; add something to clean up the shell then
  ))

;; search for goals by query

(defun freekbs2-gen-formula (predicate arguments)
 (let* ((formula nil))
  (push arguments formula)
  (push predicate formula)
  formula))

(defun freekbs2-map-function-to-formulae-made-from-entries-in-region ()
 ""
 (interactive)
 (let* (
	(action (completing-read "Action?: " '("freekbs2-assert-formula" "freekbs2-query-formula" "freekbs2-unassert-formula")))
	(predicate (freekbs2-get-predicate))
	(formulae (mapcar (lambda (arg) (freekbs2-gen-formula predicate arg)) (freekbs2-entries-in-region)))
	)
  (mapcar (lambda (arg) (eval (car (read-from-string (concat "(" action " arg)"))))) formulae)))

(defun freekbs2-entries-in-region ()
 ""
 (interactive)
 (let* ((lines (split-string (buffer-substring-no-properties (point) (mark)) "\n"))
	(entries nil))
  (mapcar 
   (lambda (arg) 
    (let ((id (freekbs2-entry arg)))
     (if (string-match "." id)		; "^\d+$"
      (push id entries))))
   lines)
  (message (prin1-to-string entries))
  entries))

(defun freekbs2-unshift-predicate-onto-stack ()
 ""
 (interactive)
 (freekbs2-push-onto-stack (freekbs2-get-predicate) nil))

(defun freekbs2-craft-not-formula ()
 ""
 (interactive)
 (setq freekbs2-stack (list "not" freekbs2-stack))
 (freekbs2-view-stack))

(defun freekbs2-craft-exists-formula ()
 ""
 (interactive)
 (setq freekbs2-stack (list "exists" "var-rand" freekbs2-stack))
 (freekbs2-view-stack))

(defun freekbs2-craft-forall-formula ()
 ""
 (interactive)
 (setq freekbs2-stack (list "forall" "var-rand" freekbs2-stack))
 (freekbs2-view-stack))

(defun freekbs2-craft-possible-formula ()
 ""
 (interactive)
 (setq freekbs2-stack (list "possible" freekbs2-stack))
 (freekbs2-view-stack))

(defun freekbs2-craft-necessary-formula ()
 ""
 (interactive)
 (setq freekbs2-stack (list "necessary" freekbs2-stack))
 (freekbs2-view-stack))

(defun freekbs2-push-metastack ()
 ""
 (interactive)
 ;; we want to take 
 (setq freekbs2-stack (list freekbs2-stack))
 (freekbs2-view-stack))

(defun freekbs2-pop-metastack (&optional arg)
 ""
 (interactive)
 (setq freekbs2-stack (car freekbs2-stack))
 (freekbs2-view-stack))

(defun freekbs2-stack-rotate-forward ()
 "Put the first element of the stack at the end"
 (interactive)
 (unshift (pop freekbs2-stack) freekbs2-stack)
 (freekbs2-view-stack)
 )

(defun freekbs2-stack-rotate-backward ()
 "Put the last element of the stack at the start"
 (interactive)
 (push (shift freekbs2-stack) freekbs2-stack)
 (freekbs2-view-stack)
 )

;; look at opencyc-el for ideas

(defun freekbs2-complete-entry ()
 ""
 )

(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/elisp-format.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-util.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-es.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-stack.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-ring.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-execute2.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-execute2-functions.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-api.el")
(load "/var/lib/myfrdcsa/codebases/internal/freekbs2/frdcsa/emacs/freekbs2-ke.el")

(freekbs2-es-mode)

(defun freekbs2-set-query ()
 "Setup for debugging purposes"
 (interactive)
 (setq freekbs2-stack '("completed" ("UniLang-Entry" var-x0)))
 (freekbs2-view-stack))

(defun freekbs2-edit-assertion ()
 "Add a function for editing a given assertion, by unasserting
 the original and asserting the edited"
 )

(defun freekbs2-push-kmax-w3m-get-a-url-onto-stack ()
 "Push the URL given onto the stack"
 (interactive)
 (freekbs2-push-onto-stack (kmax-w3m-get-a-url) nil))

(defun freekbs2-insert-top-of-stack (&optional arg)
 "Push the URL given onto the stack"
 (interactive "P")
  (if arg
   (insert (freekbs2-pop-stack-without-viewing nil))
   (insert (freekbs2-get-top-of-stack))))

(defun freekbs2-get-top-of-stack ()
 "Push the URL given onto the stack"
 (nth 0 freekbs2-stack))

(defun freekbs2-push-direct-object-onto-stack ()
 "Push the URL given onto the stack"
 (interactive)
 (freekbs2-push-onto-stack 'var-_ nil))

(defun freekbs2-condense-whitespace (text)
 "Condense the whitespace in a string, getting rid of leading and
trailing whitespace, replacing carriage return and newlines with
space, and condensing multiple spaces into one space"
 (replace-regexp-in-string "\s$" "" 
  (replace-regexp-in-string "^\s" "" 
   (replace-regexp-in-string "\s+" " " 
    (replace-regexp-in-string "[\n\r]+" " " text))
   )))

(defun freekbs2-santize-for-freekbs2 (text)
 "Condense the whitespace in a string, getting rid of leading and
trailing whitespace, replacing carriage return and newlines with
space, and condensing multiple spaces into one space"
 (replace-regexp-in-string "[^[:ascii:]]" " " text))

;; (ert-deftest freekbs2-condense-whitespace ()
;;  "Test that the whitespace is stripped properly"
;;  (should 
;;   (string= (freekbs2-condense-whitespace "

;; hello

;; there

;; ")
;;    "hello there")))

;; (ert-deftest freekbs2-condense-whitespace ()
;;  "Test that the whitespace is stripped properly"
;;  (should 
;;   (string= (freekbs2-condense-whitespace "

;; hello

;; there

;; ")
;;    "hello there")))

;; (ert-deftest freekbs2-push-pop-stack ()
;;  "ensure push and pop stack work fine"
;;  (let ((freekbs2-stack (list "a" "b" "c")))
;;   (should 
;;    (string= (freekbs2-pop-stack) "a"))))
 
;; ;; (ert-deftest freekbs2-push-pop-stack ()
;; ;;  "ensure push and pop stack work fine"
;; ;;  (let ((freekbs2-stack (list "a" "b" "c")))
;; ;;   (should 
;; ;;    (string= (freekbs2-pop-stack) "a"))))

(defun freekbs2-push-most-interesting-tag-at-point-onto-stack ()
 "Grab the most relevant item under the text cursor and put it on
the stack"
 (interactive)
 (unwind-protect
  (let ((tag (condition-case nil
	      (nlu-get-most-interesting-tag-at-point t)
	      (error (freekbs2-push-tap-onto-stack-symbol nil)))))
   (freekbs2-push-onto-stack tag nil))))

(defun freekbs2-push-most-interesting-tag-at-point-onto-stack ()
 "Grab the most relevant item under the text cursor and put it on
the stack"
 (interactive)
 (unwind-protect
  (condition-case nil
   (let ((tag (nlu-get-most-interesting-tag-at-point t)))
    (freekbs2-push-onto-stack tag nil))
   (error (freekbs2-push-tap-onto-stack-symbol nil)))))

(defun freekbs2-clear-context (&optional context force)
 ""
 (interactive)
 ;; open up a new window which shows the classifications
 (let ((command
	(concat 
	 "kbs2 "
	 (if force "-y " "")
	 "-c " 
	 (shell-quote-argument (or context freekbs2-context))
	 " clear")))
  (if force
   (shell-command-to-string command)
   (run-in-shell command))))
;;  (switch-to-buffer buffer)

(defun freekbs2-query (formula context)
 ""
 ;; FIXME: check that it's a valid formula
 (if freekbs2-verbose
  (concat "Querying " (prin1-to-string formula) " in " context))
 (freekbs2-get-details-from-result
  (freekbs2-query-formula-read-predicate formula context)))

(defun freekbs2-assert (formula context)
 ""
 ;; FIXME: check that it's a valid formula
 (if (and
      (freekbs2-assert-formula-read-predicate formula context)
      freekbs2-verbose)
  (concat "Asserted " (prin1-to-string formula) " to " context)))

(defun freekbs2-test ()
 "Run a test of the commands for asserting and unasserting"
 (interactive)

 (setq freekbs2-test-context "Org::FRDCSA::FreeKBS2::Emacs::Test")
 (setq freekbs2-view-query t)
 (setq freekbs2-view-query t)

 ;; create a new context or clean it if it already exists
 (freekbs2-clear-context freekbs2-test-context t)

 ;; assert (p 1)
 (freekbs2-assert (list "p" "1") freekbs2-test-context)

 ;; assert (not (and (p ?X) (not (p ?X))))
 (freekbs2-assert (list "not" (list "and" (list "p" 'var-X) (list "not" (list "p" 'var-X))))
  freekbs2-test-context)

 ;; query (p ?X), should give value of (((?X 1)))
 (see (freekbs2-query (list "p" 'var-X) freekbs2-test-context) 0.5)

 ;; query (p 1), should give value of t
 (see (freekbs2-query (list "p" "1") freekbs2-test-context) 0.5)

 ;; query (p 2), should give value of unknown/indep
 (see (freekbs2-query (list "p" "2") freekbs2-test-context) 0.5)

 ;; query (q 1), should give value of unknown/indep
 (see (freekbs2-query (list "q" "1") freekbs2-test-context) 0.5)

 ;; assert (=> (p ?X) (not (q ?X)))
 (freekbs2-assert
  (list "implies" 
   (list "p" 'var-X)
   (list "not"
    (list "q" 'var-X)))
  freekbs2-test-context)

 ;; query (q 1), should give value of false/nil
 (see (freekbs2-query (list "q" "1") freekbs2-test-context) 0.5)

 ;; query (not (p 1)), should give value of
 (see (freekbs2-query (list "not" (list "p" "1")) freekbs2-test-context) 0.5)

 ;; query (not (q 1)), should give value of
 (see (freekbs2-query (list "not" (list "q" "1")) freekbs2-test-context) 0.5)

 (see (freekbs2-query (list ">" "2" "1") freekbs2-test-context) 0.5)
 (see (freekbs2-query (list "equal" (list "plus" "2" "2") "4") freekbs2-test-context) 0.5)

 )

;; (setq freekbs2-temp-result '(("CycL" ((var-FILENAME "/home/andrewdo/Liu_rochester_0188E_10375.pdf") (var-TITLE "Liu_rochester_0188E_10375")) ((var-TITLE "morbini-phd-thesis") (var-FILENAME "/home/andrewdo/morbini-phd-thesis.pdf")))))

;; (freekbs2-get-variable-value-from-cycl freekbs2-temp-result 'var-FILENAME)

(defun freekbs2-get-variable-value-from-cycl (cycl symbol)
 "symbol - 'var-FILENAME"
 (interactive)
 (mapcar
  (lambda (binding1)
   (car (cdr (assoc symbol binding1)))
   )
  (freekbs2-get-cycl-from-details cycl)))

;;; Some stuff here about formulae

(defun freekbs2-formula-p (object)
 "Make sure OBJECT is a valid FreeKBS2 formula"
 (if (listp object)
  ;; make sure there are no nil answers for subformula
  (if (not (non-nil object))
   nil
   (= 
    (length 
     (kmax-grep-list
      (mapcar (lambda (subobject) (freekbs2-formula-p subobject)) object)
      (lambda (result) (not (non-nil result)))))
    0))
  (if (symbolp object)
   (freekbs2-symbol-is-freekbs2-variable-p object)
   (if (stringp object)
    t
    nil))))

(defun freekbs2-symbol-is-freekbs2-variable-p (symbol)
 ""
 (not (not (string-match "^var-\\(.+\\)$" (prin1-to-string symbol)))))

(defun freekbs2-symbol-is-freekbs2-default-variable-p (symbol)
 ""
 (not (not (string-match "^var-_$" (prin1-to-string symbol)))))

;; (defun freekbs2-get-all-unbound-variables (formula)
 
;;  )

(defun freekbs2-verify-formula-has-a-free-default-variable-p (formula)
 "Make sure FORMULA has has at least one free default variable"
 (if (listp formula)
  (>
   (length 
    (kmax-grep-list
     (mapcar 
      (lambda (subformula) 
       (freekbs2-verify-formula-has-a-free-default-variable-p subformula)) 
      formula)
     (lambda (result) (non-nil result))))
   0)
  (if (symbolp formula)
   (freekbs2-symbol-is-freekbs2-default-variable-p formula)
   nil)))

;; FIXME: Turn into erc tests
(if nil
 (progn
  (setq freekbs2-test-list-of-formula 
   (list
    ("p" 'blah)
    ("p" 'var-X1)
    ("p" 'var-_)
    ))
  (mapcar
   (lambda (formula)
    (see "" 1)
    (see formula 1)
    (see (freekbs2-formula-p formula) 1)
    (see (freekbs2-verify-formula-has-a-free-default-variable-p formula) 1))
   freekbs2-test-list-of-formula)

  (freekbs2-formula-p (list))
  (freekbs2-formula-p (list nil))
  (freekbs2-formula-p (list "p"))
  (freekbs2-formula-p (list "p" 'blah))
  (freekbs2-formula-p (list "p" 'var-_))

  (freekbs2-verify-formula-has-a-free-default-variable-p (list "p" 'var-_))

  ))

(defun freekbs2-condense-whitespace-of-tos ()
 (interactive)
 (freekbs2-push-onto-stack
  (freekbs2-condense-whitespace (freekbs2-pop-stack nil))
  nil))

(defun freekbs2-santize-for-freekbs2-the-tos ()
 (interactive)
 (freekbs2-push-onto-stack
  (freekbs2-santize-for-freekbs2 (freekbs2-pop-stack nil))
  nil))

(defun freekbs2-shell-quote-tos ()
 (interactive)
 (freekbs2-push-onto-stack
  (prin1-to-string (shell-quote-argument (freekbs2-pop-stack nil)))
  nil))

(defun freekbs2-replace-tos-with-item (item &optional redisplay)
 ""
 (pop freekbs2-stack)
 (push item freekbs2-stack)
 (freekbs2-view-ring))

;; (defun freekbs2-redisplay-if-ring-or-stack-editor-is-visible (&optional force)
;;  ""
;;  (if 
;;   (or force
;;    (kmax-buffer-type-is-visible (list 'freekbs2-ring-editor-mode)))
;;   (freekbs2-view-ring)))

;; (defun kmax-list-of-lists-of-all-frames-and-their-visible-buffers ()
;;  ""
;;  (get-buffer-window-list)
;;  )

(defun freekbs2-default-context-fn (item)
 ""
 (interactive)
 (case item
  ('academician
   "Org::FRDCSA::Academician")
  ('architect
   "Org::FRDCSA::Architect")
  (t "default")))

(defun freekbs2-isearch-forward-for-tos (&optional search)
 (interactive)
 (re-search-forward (freekbs2-get-top-of-stack)))

(provide 'freekbs2)
