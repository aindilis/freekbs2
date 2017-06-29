(global-set-key "\C-csj" 'freekbs2-execute2-emacs-function-on-stack-and-display)
(global-set-key "\C-csJ" 'freekbs2-execute2-emacs-function-on-stack-and-push-results-onto-ring)
(global-set-key "\C-csxp" 'freekbs2-execute2-perl-function-on-stack-and-display)
(global-set-key "\C-csxs" 'freekbs2-execute2-shell-command-on-stack-and-display)
(global-set-key "\C-csxo" 'freekbs2-execute2-perl-function-on-stack-and-add-to-ring)
(global-set-key "\C-csxr" 'freekbs2-execute2-perl-function-on-stack-and-add-to-ring)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Execution ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun freekbs2-execute2-emacs-function-on-stack-and-display ()
 ""
 (interactive)
 (freekbs2-view-stack)
 (sit-for 0.25)
 (message (prin1-to-string (freekbs2-execute2-emacs-function-on-stack))))

(defun freekbs2-execute2-emacs-function-on-stack-and-push-results-onto-ring ()
 ""
 (interactive)
 (freekbs2-view-stack)
 (sit-for 0.25)
 (let* ((results (freekbs2-execute2-emacs-function-on-stack)))
  (message (prin1-to-string results))
  (freekbs2-ring-push (list results))))

(defun freekbs2-execute2-emacs-function-on-tos (&optional myfunction mydata)
 ""
 (interactive)
 (let* ((stack-length (length freekbs2-stack))
	(function (if myfunction
		   myfunction
		   (completing-read (concat "Emacs Function w/" (prin1-to-string stack-length) " Args: ")
		    (kmax-grep-list
		     (mapcar 
		      (lambda (function) (prin1-to-string function))
		      (freekbs2-execute2-get-functions-with-n-arguments stack-length))
		     (lambda (function) (not (string= function "-2"))))		    
		    nil nil ""
		    )
		   ))
	(data (if mydata
	       mydata
	       (car freekbs2-stack))))
  (funcall (intern function) data)))

(defun freekbs2-execute2-emacs-function-on-stack (&optional myfunction mydata)
 ""
 (interactive)
 (let* ((stack-length (length freekbs2-stack))
	(function (if myfunction
		   myfunction
		   (completing-read (concat "Emacs Function w/" (prin1-to-string stack-length) " Args: ")
		    (kmax-grep-list
		     (mapcar 
		      (lambda (function) (prin1-to-string function))
		      (freekbs2-execute2-get-functions-with-n-arguments stack-length))
		     (lambda (function) (not (string= function "-2"))))		    
		    nil nil ""
		    )
		   ))
	(result (cond 
		 ((= stack-length 0) (funcall (intern function)))
		 ((= stack-length 1) (funcall (intern function) (nth 0 freekbs2-stack)))
		 ((= stack-length 2) (funcall (intern function) (nth 0 freekbs2-stack) (nth 1 freekbs2-stack)))
		 ((= stack-length 3) (funcall (intern function) (nth 0 freekbs2-stack) (nth 1 freekbs2-stack) (nth 2 freekbs2-stack)))
		 ((= stack-length 4) (funcall (intern function) (nth 0 freekbs2-stack) (nth 1 freekbs2-stack) (nth 2 freekbs2-stack) (nth 3 freekbs2-stack)))
		 ((= stack-length 5) (funcall (intern function) (nth 0 freekbs2-stack) (nth 1 freekbs2-stack) (nth 2 freekbs2-stack) (nth 3 freekbs2-stack) (nth 4 freekbs2-stack)))))
	)
  result
  )
 )

(defun freekbs2-execute2-with-optional (arg-list)
 "strip all args after &optional"
 (let ((outputlist nil))
  (mapcar (lambda (item) (if (not (eq item (intern "&optional"))) (push item outputlist))) arg-list)
  outputlist))

(defun freekbs2-execute2-truncate-optional (arg-list)
 "strip all args after &optional"
 (if (> (length arg-list) 1)
  (if (eq (car arg-list) (intern "&optional"))
   nil
   (cons (car arg-list) (freekbs2-execute2-truncate-optional (cdr arg-list))))
  arg-list))

(defun freekbs2-execute2-get-functions-with-n-arguments (n)
 ""
 (mapcar
  (lambda (function-name)
   (let* ((function (intern function-name))
	  (arg-list (help-function-arglist function))
	  (arg-list-length-lower-bound (if (listp arg-list) (length (freekbs2-execute2-truncate-optional arg-list)) -1))
	  (arg-list-length-upper-bound (if (listp arg-list) (length (freekbs2-execute2-with-optional arg-list)) -1)))
    (if (and 
	 (>= n arg-list-length-lower-bound)
	 (<= n arg-list-length-upper-bound)
	 )
     function
     -2)))
  (all-completions "" obarray 'functionp)))


(help-function-arglist 'kmax-grep-list-regexp)

(defun freekbs2-execute2-perl-function-on-stack-and-add-to-ring ()
 ""
 (interactive)
 (freekbs2-ring-add-result (freekbs2-execute2-perl-function-on-stack)))

(defun freekbs2-execute2-perl-function-on-stack-and-display ()
 ""
 (interactive)
 (message (prin1-to-string (freekbs2-execute2-perl-function-on-stack))))



(defun freekbs2-execute2-perl-function-on-stack (&optional myfunction mydata)
 "Run Sayer on the freekbs2-stack"
 (interactive)
 (let* ((function (if myfunction
		   myfunction
		   (completing-read "Perl KMax Function: " 
		    (uea-query-agent "functions" "KMax"
		     (freekbs2-util-data-dumper
		      (list
		       (cons "_DoNotLog" 1)
		       )
		      )))))
	(data (if mydata
	       mydata
	       (car freekbs2-stack)))
	(message (uea-query-agent-raw "execute" "KMax"   
		  (freekbs2-util-data-dumper
		   (list
		    (cons "_DoNotLog" 1)
		    (cons "Key" function)
		    (cons "Data" (list (list (cons "Text" data))))
		    )
		   )))
	(result (nth 5 message))
	(alist (freekbs2-util-data-dedumper result)))
  (cdr (assoc "_Result" alist))
  )
 )

(setq freekbs2-shell-commands '("ls" "ps"))

(defun freekbs2-execute2-shell-command-on-stack-and-add-to-ring ()
 ""
 (interactive)
 (freekbs2-ring-add-result (freekbs2-execute2-shell-command-on-stack)))

(defun freekbs2-execute2-shell-command-on-stack-and-display ()
 ""
 (interactive)
 (message (prin1-to-string (freekbs2-execute2-shell-command-on-stack))))

(defun freekbs2-execute2-shell-command-on-stack (&optional mycommand mydata)
 "Execute a shell command, such as radar-web-search, on the data"
 (interactive)
 (let* ((command (if mycommand
		   mycommand
		   (completing-read "Shell Command: " freekbs2-shell-commands)))
	(data (if mydata
	       mydata
	       (car freekbs2-stack))))
  (shell-command-to-string (concat command " " (shell-quote-argument data)))))

;; add the capability to check the type of the arguments in freekbs2,
;; using the sayer system and duck typing or type predicates, etc, and
;; use that information, and have the ability to search for functions
;; which use those.  So for instance, if I have a string containing
;; text.  add other key bindings for other types of executors, such as
;; an executor that will list certain types of functions to call, such
;; as functions which have a certain tag, or which will return values
;; to the freekbs2 stack or ring, hrm, use C-c x

;; some functions to eventually write, split by character

;; add the ability to call functions with a range of number of
;; arguments determined from the &optional parameter in the arg list

;; add the ability to call interactive functions on the stack using their keybinding

;; make object oriented, with affordances

;; have the ability to invoke object oriented Moose/eieio code etc using
;; duck typing and introspection, if that makes sense

;; get rid of -1 and -2 showing up in the function list

;; have the ability to run text processing such as information
;; extraction, noun phrase extraction, etc

;; read the original emacs and lisp mit papers

;; create a directory, probably in digilib, that contains those emacs
;; papers

;; have it learn which functions you commonly call on certain type of objects





;; add stuff for stderr, stdout, etc, add buffer stuffer

;; paragraph splitter

;; (defun freekbs2-list-all-shell-commands (&optional interactively)
;;  "Support extensible programmable completion.
;; To use this function, just bind the TAB key to it, or add it to your
;; completion functions list (it should occur fairly early in the list)."
;;  (interactive "p")
;;  (let* ((mylist nil))
;;   (if (and interactively
;;        pcomplete-cycle-completions
;;        pcomplete-current-completions
;;        (memq last-command '(pcomplete
;; 			    pcomplete-expand-and-complete
;; 			    pcomplete-reverse)))
;;    (progn
;;     (delete-backward-char pcomplete-last-completion-length)
;;     (if (eq this-command 'pcomplete-reverse)
;;      (progn
;;       (setq pcomplete-current-completions
;;        (cons (car (last pcomplete-current-completions))
;; 	pcomplete-current-completions))
;;       (setcdr (last pcomplete-current-completions 2) nil))
;;      (nconc pcomplete-current-completions
;;       (list (car pcomplete-current-completions)))
;;      (setq pcomplete-current-completions
;;       (cdr pcomplete-current-completions)))
;;     (push (car pcomplete-current-completions) mylist))
;;    (setq pcomplete-current-completions nil
;;     pcomplete-last-completion-raw nil)
;;    (catch 'pcompleted
;;     (let* ((pcomplete-stub)
;; 	   pcomplete-seen pcomplete-norm-func
;; 	   pcomplete-args pcomplete-last pcomplete-index
;; 	   (pcomplete-autolist pcomplete-autolist)
;; 	   (pcomplete-suffix-list pcomplete-suffix-list)
;; 	   (completions (pcomplete-completions))
;; 	   (result (pcomplete-do-complete pcomplete-stub completions)))
;;      (and result
;;       (not (eq (car result) 'listed))
;;       (cdr result)
;;       (push (cdr result) mylist)))))
;;   (prin1-to-string mylist)))

;; various modes, replace the current item, add result to end, add result to new item in ring, etc
;; functions to grab sentences
;; functions to process sentences into parts, such as extract named entities from text, etc
;; interface with sayer, and the like, prove things about the text at
;; point, add those onto the ring or some such thing
;; should have the ability to assign text-properties based on results of this

;; need to get emacs functions that apply here, maybe some kind of
;; type system???

;; take the first item on the stack, and operate on it
;; 

;; get the function, and then call it on the first argument of the
;; stack, make sure also that it only takes one arg, or in the
;; future, pass as much of the stack as args to the function as
;; necessary

;; ;; (message (prin1-to-string (funcall (intern function) (car freekbs2-stack))))
;; now we want to send the contents to kmax for evaluation and do I
;; don't know what yet with the results, other than that all perl
;; data structures should be converted to lisp ones
