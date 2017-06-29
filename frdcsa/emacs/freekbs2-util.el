
(defun freekbs2-util-data-dumper (item)
 "Generates a perl Data::Dumper result for an emacs data structure"
 (concat "$VAR1 = " (freekbs2-util-convert-from-emacs-to-perl-data-structures item) ";")
 )

(defun freekbs2-util-data-dedumper-orig (item)
 "Converts a perl Data::Dumper result into an emacs data structure"
 (let* ((result (shell-command-to-string
		 (concat "/var/lib/myfrdcsa/codebases/internal/unilang/scripts/convert-perl-data-dumper-to-emacs-data.pl "
		  (shell-quote-argument item)))))
  ;; (message result)
  ;; (sit-for 5)
  (eval (read (concat "'" result)))))

(defun freekbs2-util-data-dedumper (item)
 "Converts a perl Data::Dumper result into an emacs data structure"

 (let* (
	(filename (make-temp-file "freekbs2-"))
	)
  (write-region item nil filename nil 'silent)
  (let* ((result (shell-command-to-string
		 (concat "/var/lib/myfrdcsa/codebases/internal/unilang/scripts/convert-perl-data-dumper-to-emacs-data-2.pl "
		  (shell-quote-argument filename)))))
   (eval (read (concat "'" result)))
   )))

;; (freekbs2-util-convert-from-emacs-to-perl-data-structures "#$\"test")

(defun freekbs2-util-convert-from-emacs-to-perl-data-structures (item)
 "Convert this emacs data structure into a perl equivalent"
 (message "%s" (prin1-to-string item))
 (if (listp item)
  (if (alistp item)
   (concat				; this is an alist i.e. hash
    "{"
    (join ", " (mapcar 'freekbs2-util-make-hash-pair item))
    "}"
    )
   (concat 				; this is a regular list
    "[" 
    (join ", " (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures item))
    "]")					
   )
  (if (stringp item)
   (concat "\"" 
    (join "" 
     (mapcar (lambda (char) 
	      (if (or (string= char "$")
		   (string= char "\\")
		   (string= char "\"")
		   (string= char "'")
		   (string= char "@")
		   (string= char "%")
		   (string= char "@")
		   )
	       (concat (prin1-to-string "\\" t) char) char)
	      ) (split-string item ""))) "\"")
   (if nil
    (concat "\"" (prin1-to-string item) "\"")
    (let* ((result (prin1-to-string item))
	   (match (progn (string-match "^var-\\(.+\\)$" result) (match-string 1 result))))
     (if (non-nil match)
      (concat "\\*{'::?" match "'}")
      (concat "\"" result "\"")))))))

  ;; (replace-regexp-in-string "\\$" (prin1-to-string "\$" t) (prin1-to-string item) t t)
  ;; (prin1-to-string item t)
  ;; (let ((item "#$tem"))
  ;;  (replace-regexp-in-string "\\$" (prin1-to-string "\\$" t) (prin1-to-string item t) t t))
  ;; (let ((item "#$item"))
  ;;  (replace-regexp-in-string "\\$" (concat (make-string 1 ?\\) "$") (prin1-to-string item) t t))
  ;; (replace-regexp-in-string "\\$" (concat (make-string 1 ?\\) "$") (prin1-to-string item) t t))
  ;; (replace-in-string (prin1-to-string item) "$" "__DOLLAR_SIGN____ANDY__")
  ;; (replace-in-string (prin1-to-string "$") "\\$" "\\\\$")
  ;; (replace-regexp-in-string "\\$" "\$" (prin1-to-string item) t t)


(defun freekbs2-util-make-hash-pair (item)
 ""
 (concat 
  (freekbs2-util-convert-from-emacs-to-perl-data-structures (car item))
  " => "  
  (freekbs2-util-convert-from-emacs-to-perl-data-structures (cdr item))
  )
 )

(defun alistp (list)
 "Check if the list is an alist"
 (when (listp list)
  (let ((quit nil))
   (while (and (consp list) (not quit))
    (if (and 
	 (consp (car list))
	 (not (null (cdar list)))
	 )
     (setq list (cdr list))
     (setq quit t)
     )
    )
   )
  (null list)))
