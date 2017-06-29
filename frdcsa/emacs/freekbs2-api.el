;; This is designed to develop better tools for conversing with
;; Freekbs2 from Emacs

;; FIX ALL THIS CRAP, IT DON"T WORK!


(defun freekbs2-api-assert-relation (relation context)
 ""
 (interactive)
 (freekbs2-api-send-command "assert" relation context)
 )

(defun freekbs2-api-unassert-relation (relation context)
 ""
 (interactive)
 (freekbs2-api-send-command "unassert" relation context)
 )

(defun freekbs2-api-query-relation (relation context)
 ""
 (interactive)
 (freekbs2-api-send-command "query" relation context)
 )

(defun freekbs2-api-send-command (command relation context)
 "Send a command"
 (interactive)
 (let
  ((mymessage (concat context " " command " " (freekbs2-print-relation relation))))
  (if (string-match-p "^[qQ][uU][eE][rR][yY]$" command)
   (let*
    ((message (uea-query-agent-raw mymessage "KBS2"   
	       (freekbs2-util-data-dumper
		(list
		 (cons "_DoNotLog" 1)
		 )
		)))
     (result (nth 5 message))
     (alist (freekbs2-util-data-dedumper result)))
    alist)
   (progn
    (uea-send-contents mymessage)
    (message mymessage)
    )
   )
  )
 )

;; (freekbs2-print-relation freekbs2-stack)
;; (freekbs2-api-query-relation freekbs2-stack "default")

(defun freekbs2-query-ping (command relation context)
 "Send a command"
 (interactive)
 (let*
  ((message (uea-query-agent-raw "echo hi" "KBS2"   
	     (freekbs2-util-data-dumper
	      (list
	       (cons "_DoNotLog" 1)
	       )
	      )))
   ;; (result (nth 5 message))
   ;; (alist (freekbs2-util-data-dedumper result)))
   )
  ;; alist
  result
  )
 )
