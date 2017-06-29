(global-set-key "\C-csXe" 'freekbs2-execute-emacs-function-on-stack-and-display)
(global-set-key "\C-csXp" 'freekbs2-execute-perl-function-on-stack-and-display)
(global-set-key "\C-csXs" 'freekbs2-execute-shell-command-on-stack-and-display)

(global-set-key "\C-csO" 'freekbs2-execute-perl-function-on-stack-and-add-to-ring)
(global-set-key "\C-csXr" 'freekbs2-execute-perl-function-on-stack-and-add-to-ring)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Execution ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun freekbs2-execute-emacs-function-on-stack-and-display ()
 ""
 (interactive)
 (message (prin1-to-string (freekbs2-execute-emacs-function-on-stack))))

(defun kmax-grep-list (list regexp)
 "accept a list and grep through the list for matches, returning the matching list"
 (let ((outputlist nil))
  (mapcar (lambda (item) (if (string-match regexp item) (push item outputlist))) list)
  outputlist))

;; (kmax-grep-list (list "a" "b" "c") "^a")

(defun freekbs2-execute-emacs-function-on-stack (&optional myfunction mydata)
 ""
 (interactive)
 (let* ((function (if myfunction
		   myfunction
		   (completing-read "Emacs Function: "
		    (kmax-grep-list (all-completions "" obarray 'functionp) "^freekbs2-execute-functions-")
		    ;; (all-completions "" obarray 'functionp)
		    nil nil "freekbs2-execute-functions-"
		    )))
	(data (if mydata
	       mydata
	       (car freekbs2-stack)))
	)
  (message (prin1-to-string (funcall (intern function) data)))
  )
 )

(defun freekbs2-execute-perl-function-on-stack-and-add-to-ring ()
 ""
 (interactive)
 (freekbs2-ring-add-result (freekbs2-execute-perl-function-on-stack)))

(defun freekbs2-execute-perl-function-on-stack-and-display ()
 ""
 (interactive)
 (message (prin1-to-string (freekbs2-execute-perl-function-on-stack))))

(defun freekbs2-execute-perl-function-on-stack (&optional myfunction mydata)
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

(defun freekbs2-execute-shell-command-on-stack-and-add-to-ring ()
 ""
 (interactive)
 (freekbs2-ring-add-result (freekbs2-execute-shell-command-on-stack)))

(defun freekbs2-execute-shell-command-on-stack-and-display ()
 ""
 (interactive)
 (message (prin1-to-string (freekbs2-execute-shell-command-on-stack))))

(defun freekbs2-execute-shell-command-on-stack (&optional mycommand mydata)
 "Execute a shell command, such as radar-web-search, on the data"
 (interactive)
 (let* ((command (if mycommand
		   mycommand
		   (completing-read "Shell Command: " freekbs2-shell-commands)))
	(data (if mydata
	       mydata
	       (car freekbs2-stack))))
  (shell-command-to-string (concat command " " (shell-quote-argument data)))))

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
