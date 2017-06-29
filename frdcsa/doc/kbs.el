;; kbs.el

(setq kbs-buffer-name "*kbs*")
(setq kbs-store "MySQL:score:default")

;; (load-library "dired")
;; (define-key dired-mode-map "z"
;;   'ffap-to-killring)
;; ;; 'kbs-add-to-related-files

;; (defun ffap-to-killring ()
;;   ""
;;   (interactive)
;;   (kill-new (ffap-prompter)))

;; (defun kbfs-add-to-related-files ()
;;   "a dired function that adds a given filename to a list of
;; relevant file names for a given project or functionality"
;;   (interactive)
;;   (shell-command (concat "echo " (ffap-prompter) " >> /var/lib/myfrdcsa/codebases/internal/kbs/data/related-systems.txt"))
;;   )

;; (defun kbfs-record-gem ()
;;   "a dired function that adds a given filename to a list of
;; relevant file names for a given project or functionality"
;;   (interactive)
;;  ;; (shell-command (concat "echo " (ffap-prompter) " >> /var/lib/myfrdcsa/codebases/internal/kbs/data/milestones.txt"))
;;   )

(setq kbs-stack nil)

(global-set-key "\C-csg" 'kbs-push-eap-onto-stack)
(global-set-key "\C-css" 'kbs-push-symbol-onto-stack)
(global-set-key "\C-csy" 'kbs-push-yank-onto-stack)
(global-set-key "\C-csr" 'kbs-push-read-from-minibuffer-onto-stack)
(global-set-key "\C-csn" 'kbs-push-undef-onto-stack)
(global-set-key "\C-csa" 'kbs-assert-relation)
(global-set-key "\C-csc" 'kbs-clear-stack)
(global-set-key "\C-cst" 'kbs-push-tap-onto-stack)
(global-set-key "\C-csu" 'kbs-unassert-relation)
(global-set-key "\C-csq" 'kbs-query-relation)
(global-set-key "\C-csv" 'kbs-view-stack)
(global-set-key "\C-csp" 'kbs-pop-stack)

(global-set-key "\C-cshc" 'kbs-shortcut-mark-as-completed)

(setq kbs-predicates
      '(("depends" . (("Arity" . 2)))
	("delete" . (("Arity" . 1)))
	("completed" . (("Arity" . 1)))
	("not interested in working on" . (("Arity" . 2)))
	("is part of" . (("Arity" . 3)))
	("is more kbsal than" . (("Arity" . 3)))
	("is directly work related" . (("Arity" . 3)))
	("is a target of opportunity" . (("Arity" . 3)))
	("is fun to work on" . (("Arity" . 3)))
	("is an operations problem" . (("Arity" . 3)))
	("is more of this than that" . (("Arity" . 3)))
	))

(setq kbs-tap-types
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

(defun kbs-edit-stack ()
 "edit the stack in the minibuffer"
 (interactive)
 ;; find some way to edit the stack in the minibuffer
 ;; open buffer
 ;; (prin1-to-string 'kbs-stack)
 ;; edit this and then set it
 ;; (setq 'kbs-stack (eval (car (read-from-string string))
 )

(defun kbs-eap ()
  "Goal at point"
  (interactive)
  ;; send this information to kbs to retrieve the goal
  ;; (in the future this code should contact the user asking them to verify the item if its a single perfect match)
  (shell-command-to-string
   (concat "/var/lib/myfrdcsa/codebases/internal/kbs/scripts/lookup-entry.pl "
    (shell-quote-argument (thing-at-point 'line)))))

(defun kbs-push-undef-onto-stack ()
  "Push the goal at point onto a list of goals for use in the RPN system."
  (interactive)
  (kbs-push-onto-stack nil)
  )

(defun kbs-push-eap-onto-stack ()
  "Push the goal at point onto a list of goals for use in the RPN system."
  (interactive)
  (kbs-push-onto-stack (kbs-eap))
  )

(defun kbs-push-symbol-onto-stack ()
  "Push the goal at point onto a list of goals for use in the RPN system."
  (interactive)
  (kbs-push-onto-stack (thing-at-point 'symbol))
  )

(defun kbs-push-yank-onto-stack ()
  "Push the goal at point onto a list of goals for use in the RPN system."
  (interactive)
  (kbs-push-onto-stack (yank))
  )

(defun kbs-push-read-from-minibuffer-onto-stack ()
  "Push the goal at point onto a list of goals for use in the RPN system."
  (interactive)
  (kbs-push-onto-stack (read-from-minibuffer "Argument: "))
  )

(defun kbs-push-tap-onto-stack ()
  "Push the thing at point onto the stack, give a choice of things."
  (interactive)
  (kbs-push-onto-stack
   (eval
    (car
     (read-from-string
      (concat "(thing-at-point '" (completing-read "Type: " kbs-tap-types) ")")
      )
     )
    )
   )
  )

(defun kbs-push-onto-stack (items)
  "Push the goal at point onto a list of goals for use in the RPN system."
  (interactive)
  (push items kbs-stack)
  (kbs-view-stack)
  )

(defun kbs-pop-stack ()
  "Push the goal at point onto a list of goals for use in the RPN system"
  (interactive)
  (pop kbs-stack)
  (kbs-view-stack)
  )

(defun kbs-send-command (command relation)
  "Send a command"
  (interactive)
  (let
   ((mymessage (concat "KBS, " kbs-store " " command " " (prin1-to-string relation))))
   (uea-send-contents mymessage)
   (message mymessage)
   )
  )

(defun kbs-assert-relation (&optional relation)
  "Apply a function to the stack, checking arity constraints over multiple function definitions"
  (interactive)
  (kbs-send-command "assert" (if relation
			      relation
			      (kbs-get-relation)))
  (kbs-clear-stack)
  )

(defun kbs-unassert-relation (&optional relation)
  "Apply a function to the stack, checking arity constraints over multiple function definitions"
  (interactive)
  (kbs-send-command "unassert" (if relation
				relation
				(kbs-get-relation)))
  (kbs-clear-stack)
  )

(defun kbs-query-relation (&optional relation)
  "Apply a function to the stack, checking arity constraints over multiple function definitions"
  (interactive)
  (kbs-send-command "query" (if relation
			     relation
			     (kbs-get-relation)))
  (kbs-clear-stack)
  )

(defun kbs-get-relation ()
  ""
  (let (
	(x (append (list (completing-read "Predicate: " kbs-predicates)) kbs-stack))
	)
   ; (kbs-clear-stack)
    x)
  )

(defun kbs-view-stack ()
  ""
 (interactive)
 (message (prin1-to-string kbs-stack)))

(defun kbs-clear-stack ()
  ""
  (interactive)
  (setq kbs-stack nil))

(defun kbs-edit-stack ()
  "Edit the stack"
  ;; need to know which position
  )

(defun kbs-undo ()
 "Undo the last critique"
 )

;; (defun kbs-list-eap-relations ())
;; (defun kbs-edit-eap-relations ())

;; (defun kbs-eap-in-region ())



















;; an earlier api design

(defun kbs-mode ()
 "A minor mode for reviewing items")

(defun kbs-next ()
 "Jump to next item in list")

(defun kbs-previous ()
 "Jump to previous item in list")

(defun kbs-search ()
 "search for matching items")

(defun kbs-rate ()
 "")

(defun kbs-classify ()
 "")

(defun kbs-relate ()
 "")

(defun kbs-compare ()
 "")

(defun kbs-reload ()
 "")

(defun kbs-resort ()
 "")

;; selection algebra

(defun kbs-select ()
 "")

(defun kbs-deselect ()
 "")

(defun kbs-select-all ()
 "")

(defun kbs-deselect-all ()
 "")

(defun kbs-select-region ()
 "")

(defun kbs-deselect-region ()
 "")

(defun kbs-push-up ()
 "")

(defun kbs-push-down ()
 "")

(defun kbs-view ()
 "")

;; unary predicates 
