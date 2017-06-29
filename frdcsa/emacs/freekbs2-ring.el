(setq vc-handled-backends nil)

(define-derived-mode freekbs2-ring-editor-mode
 emacs-lisp-mode "FreeKBS2-Ring-Editor"
 "Major mode for rapid manipulation of symbolic ring.
\\{freekbs2-ring-editor-mode-map}"
 (setq case-fold-search nil)
 (define-key freekbs2-ring-editor-mode-map "f" 'freekbs2-ring-rotate-ring-forward)
 (define-key freekbs2-ring-editor-mode-map "b" 'freekbs2-ring-rotate-ring-backward)
 (define-key freekbs2-ring-editor-mode-map "p" 'freekbs2-ring-pop)
 (define-key freekbs2-ring-editor-mode-map "o" 'freekbs2-ring-pop-onto-clipboard)
 (define-key freekbs2-ring-editor-mode-map "u" 'freekbs2-ring-push-from-clipboard)
 (define-key freekbs2-ring-editor-mode-map "s" 'freekbs2-ring-shift)
 (define-key freekbs2-ring-editor-mode-map "ia" 'freekbs2-ring-insert-first-stack-arg)
 (define-key freekbs2-ring-editor-mode-map "is" 'freekbs2-ring-insert-stack)
 (define-key freekbs2-ring-editor-mode-map "ir" 'freekbs2-ring-insert-ring)
 ;; (define-key freekbs2-ring-editor-mode-map "\C-s" 'freekbs2-ring-search-previous)
 (define-key freekbs2-ring-editor-mode-map "v" 'freekbs2-view-ring)
 (define-key freekbs2-ring-editor-mode-map "V" 'freekbs2-view-ring-message-buffer)
 ;; (define-key freekbs2-ring-editor-mode-map "c" 'freekbs2-ring-clear)
 (define-key freekbs2-ring-editor-mode-map "x" 'freekbs2-ring-load-samples)
 (define-key freekbs2-ring-editor-mode-map "2" 'freekbs2-ring-push-copy-of-stack)

 (define-key freekbs2-ring-editor-mode-map "I" 'freekbs2-ring-craft-implies-formula)
 (define-key freekbs2-ring-editor-mode-map "&" 'freekbs2-ring-craft-and-formula)
 (define-key freekbs2-ring-editor-mode-map "|" 'freekbs2-ring-craft-or-formula)

 (define-key freekbs2-ring-editor-mode-map "q" 'quit-window)
 (suppress-keymap freekbs2-ring-editor-mode-map)
 )

(global-set-key "\C-csrf" 'freekbs2-ring-rotate-ring-forward)
(global-set-key "\C-csrb" 'freekbs2-ring-rotate-ring-backward)
(global-set-key "\C-csrp" 'freekbs2-ring-pop)
(global-set-key "\C-csro" 'freekbs2-ring-pop-onto-clipboard)
(global-set-key "\C-csru" 'freekbs2-ring-push-from-clipboard)
(global-set-key "\C-csrs" 'freekbs2-ring-shift)
(global-set-key "\C-csria" 'freekbs2-ring-insert-first-stack-arg)
(global-set-key "\C-csris" 'freekbs2-ring-insert-stack)
(global-set-key "\C-csrir" 'freekbs2-ring-insert-ring)
(global-set-key "\C-csr\C-s" 'freekbs2-ring-search-previous)
(global-set-key "\C-csrv" 'freekbs2-view-ring)
(global-set-key "\C-csrV" 'freekbs2-view-ring-message-buffer)
(global-set-key "\C-csrc" 'freekbs2-ring-clear)
(global-set-key "\C-csrx" 'freekbs2-ring-load-samples)
(global-set-key "\C-csr2" 'freekbs2-ring-push-copy-of-stack)

(global-set-key "\C-csrI" 'freekbs2-ring-craft-implies-formula)
(global-set-key "\C-csr&" 'freekbs2-ring-craft-and-formula)
(global-set-key "\C-csr|" 'freekbs2-ring-craft-or-formula)

;; create a craft & and craft | that operates on all the items on the ring

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Freekbs2 Stack Ring ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the ring is conceived as a list with 0th element the variable
;; freekbs2-stack and then the first element of the list is the send
;; element of the ring and so on

;; so rotating forward would be to push the current stack to the front
;; of the list, and moving the last element of the list to the
;; freekbs2-stack, rotating backward would be moving the freekbs2-stack
;; to the end of the list, and shifting the front of the list into
;; freekbs2-stack

;; We can adjust later once we figure out what makes more sense to be
;; called forward and backward

(setq freekbs2-ring (make-ring 25))

(defun freekbs2-ring-rotate-ring-forward ()
 "Rotates the stack ring forward.  This means that the
freekbs2-stack becomes the oldest element, and the second newest
element becomes the freekbs2-stack"
 (interactive)
 (ring-insert-at-beginning freekbs2-ring freekbs2-stack)
 (setq freekbs2-stack (ring-ref freekbs2-ring 0))
 (ring-remove freekbs2-ring 0)
 (freekbs2-view-ring)
 )

(defun freekbs2-ring-rotate-ring-backward ()
 "Rotates the stack ring"
 (interactive)
 (ring-insert freekbs2-ring freekbs2-stack)
 (setq freekbs2-stack (ring-ref freekbs2-ring (- (ring-length freekbs2-ring) 1)))
 (ring-remove freekbs2-ring nil)
 (freekbs2-view-ring)
 )

(defun freekbs2-ring-push (&optional value)
 "Adds a new stack to the stack ring"
 (interactive)
 (if (not (equal freekbs2-stack nil))
  (ring-insert freekbs2-ring freekbs2-stack))
 (setq freekbs2-stack (if value value nil))
 (freekbs2-view-ring)
 )

(defun freekbs2-ring-add-result (value)
 "Adds a computation result to the second place, ie newest item on the ring"
 (interactive)
 (if (not (null value))
  (ring-insert freekbs2-ring value))
 (freekbs2-view-ring))

(defun freekbs2-ring-pop ()
 "Pops the ring"
 ;; FIXME: it went from (NIL (A) (B)) to ((B) (A))
 (interactive)
 (if (not (ring-empty-p freekbs2-ring))
  (progn
   (let ((result freekbs2-stack))
    (setq freekbs2-stack (ring-ref freekbs2-ring 1))
    (ring-remove freekbs2-ring 1)
    (freekbs2-view-ring)
    result
    )
   )
  (progn
   (setq freekbs2-stack nil)
   (freekbs2-view-ring)
   )))

(defun freekbs2-ring-shift ()
 "Pops the ring"
 (interactive)
 (if (not (ring-empty-p freekbs2-ring))
  (let ((result (ring-remove freekbs2-ring (- (ring-length freekbs2-ring) 1))))
   (freekbs2-view-ring)
   result
   )
  (progn
   (setq freekbs2-stack nil)
   (freekbs2-view-ring)
   )))

(defun freekbs2-ring-insert-first-stack-arg ()
 "Pretty print the stack and insert into the current buffer"
 (interactive)
 (insert (prin1-to-string (nth 0 freekbs2-stack))) 
 )

(defun freekbs2-ring-insert-stack ()
 "Pretty print the stack and insert into the current buffer"
 (interactive)
 (insert (prin1-to-string freekbs2-stack)) 
 )

(defun freekbs2-ring-insert-ring ()
 "Pretty print the stack and insert into the current buffer"
 (interactive)
 (insert (prin1-to-string (cons freekbs2-stack (ring-elements freekbs2-ring))))
 )

(defun freekbs2-ring-search-previous ()
 "Pretty print the stack and insert into the current buffer"
 (interactive)
 )

(setq freekbs2-view-ring-function "(freekbs2-view-ring-message-buffer)")

(defun freekbs2-view-ring ()
 ""
 (interactive)
 (eval (read freekbs2-view-ring-function)))

(defun freekbs2-view-ring-message ()
 ""
 (interactive)
 (message
  (freekbs2-ring-print)))

(defvar freebs2-view-ring-buffer-name "*FreeKBS2 View Ring*")

(defun freekbs2-view-ring-message-buffer ()
 ""
 (interactive)
 (kmax-util-message-buffer freebs2-view-ring-buffer-name (freekbs2-ring-print))
 (freekbs2-ring-editor-mode))

;; going to have to have something that replaces each quoted item with
;; a symbol the same size, then format it, then substitute the quoted
;; terms back for the unique terms

(defun freekbs2-special-print-substitution-test (formula)
 ""
 (dolist (item formula) 
  (if (listp item)
   (freekbs2-special-print-substitution-test item)
   (see item))))

(defun freekbs2-special-print-substitution (formula)
 ""
 (let*
  ((mylist nil))
  (dolist (item formula) 
   (if (listp item)
    (unshift (freekbs2-special-print-substitution item) mylist)
    (let* 
     ((stringversion (if (stringp item)
		      item
		      (prin1-to-string item)))
      (extra-characters (- (length stringversion) (length (int-to-string freekbs2-special-print-counter))))
      (substitution (progn
		     (setq freekbs2-special-padding "")
		     (dotimes (i extra-characters)
		      (setq freekbs2-special-padding (concat "X" freekbs2-special-padding)))
		     (setq freekbs2-special-print-counter (+ 1 freekbs2-special-print-counter))
		     (concat (int-to-string freekbs2-special-print-counter) freekbs2-special-padding)
		     )))
     (puthash substitution item freekbs2-special-hash)
     (unshift (read substitution) mylist))))
  mylist))

(defun freekbs2-special-print-ring () 
 ""
 (interactive)
 (setq freekbs2-special-print-counter 0)
 (setq freekbs2-special-hash (make-hash-table))
 (let* ((formatted (pp
		    (freekbs2-special-print-substitution
		     (cons freekbs2-stack (ring-elements freekbs2-ring)))))
	(substituted (freekbs2-special-substitute-hash-values-into-string formatted)))))

(defun freekbs2-special-substitute-hash-values-into-string (formatted)
 (interactive)
 )

(defun freekbs2-ring-print ()
 ""
 (pp
  (cons freekbs2-stack
   (ring-elements freekbs2-ring))))

(defun freekbs2-ring-load-samples ()
 ""
 (interactive)
 (freekbs2-ring-add-new-stack)
 (freekbs2-push-onto-stack "test1.1" nil)
 (freekbs2-push-onto-stack "test1.2" nil)
 (freekbs2-ring-add-new-stack)
 (freekbs2-push-onto-stack "test2.1" nil)

 (freekbs2-view-ring)
 )



(defun freekbs2-ring-clear (&optional arg)
 ""
 (interactive "P")
 (if (not arg)
  (progn
   (setq freekbs2-stack nil)
   (setq freekbs2-ring (make-ring 25))
   )
  (progn
   (setq freekbs2-ring (make-ring 25))))
 (freekbs2-view-ring)
 )


(defun elisp-format-string (string)
 ""
 (interactive)
 (with-temp-buffer
  (emacs-lisp-mode)
  (insert string)
  (elisp-format-buffer)
  (mark-whole-buffer)
  (buffer-substring-no-properties (mark) (point))))

(defun freekbs2-ring-craft-implies-formula ()
 ""
 (interactive)
 (freekbs2-ring-push (list "implies" (freekbs2-ring-pop) (freekbs2-ring-pop))))

(defun freekbs2-ring-craft-and-formula ()
 ""
 (interactive)
 (freekbs2-ring-push (list "and" (freekbs2-ring-pop) (freekbs2-ring-pop))))

(defun freekbs2-ring-craft-or-formula ()
 ""
 (interactive)
 (freekbs2-ring-push (list "or" (freekbs2-ring-pop) (freekbs2-ring-pop))))

(defun freekbs2-ring-pop-onto-clipboard-orig ()
 ""
 (interactive)
 (kmax-fixme "")
 ;; (shell-command (concat "echo " "test" " | xclip -i"))
 (shell-command (concat "echo " (shell-quote-argument (freekbs2-ring-pop)) " | xclip -i")))

(defun freekbs2-ring-pop-onto-clipboard ()
 ""
 (interactive)
 (kmax-fixme "")
 ;; (shell-command (concat "echo " "test" " | xclip -i"))
 (shell-command (concat "echo " (shell-quote-argument (freekbs2-get-top-of-stack)) " | xclip -i")))


(defun freekbs2-ring-push-from-clipboard ()
 ""
 (interactive)
 ;; FIX ME
 (freekbs2-ring-push (shell-command-to-string  "xclip -o")))

(defun freekbs2-ring-push-copy-of-stack ()
 ""
 (interactive)
 (freekbs2-ring-push freekbs2-stack))

;; create a mode here for editing and browsing and more rapidly
;; working with the ring

;; put region into ring, in case you have many assertions in the region
