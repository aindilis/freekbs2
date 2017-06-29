;;; freekbs2-es.el --- switch between buffers using substrings

;; Copyright (C) 1996, 1997, 2000, 2001, 2002, 2003, 2004,
;;   2005, 2006, 2007, 2008 Free Software Foundation, Inc.

;; Author: Stephen Eglen <stephen@gnu.org>
;; Maintainer: Stephen Eglen <stephen@gnu.org>
;; Keywords: completion convenience

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Installation:
;; To get the functions in this package bound to keys, use
;; M-x freekbs2-es-mode or customize the option `freekbs2-es-mode'.
;; Alternatively, add the following line to your .emacs:
;; (freekbs2-es-mode 1)

;; As you type in a substring, the list of buffers currently matching
;; the substring is displayed as you type.  The list is ordered so
;; that the most recent buffers visited come at the start of the list.
;; The buffer at the start of the list will be the one visited when
;; you press return.  By typing more of the substring, the list is
;; narrowed down so that gradually the buffer you want will be at the
;; top of the list.  Alternatively, you can use C-s and C-r to rotate
;; buffer names in the list until the one you want is at the top of
;; the list.  Completion is also available so that you can see what is
;; common to all of the matching buffers as you type.

;; This code is similar to a couple of other packages.  Michael R Cook
;; <cook@sightpath.com> wrote a similar buffer switching package, but
;; does exact matching rather than substring matching on buffer names.
;; I also modified a couple of functions from icomplete.el to provid
;; the completion feedback in the minibuffer.

;;; Example

;; If I have two buffers called "123456" and "123", with "123456" the
;; most recent, when I use freekbs2-es, I first of all get presented with
;; the list of all the buffers
;;
;;       iswitch  {123456,123}
;;
;; If I then press 2:
;;       iswitch 2[3]{123456,123}
;;
;; The list in {} are the matching buffers, most recent first (buffers
;; visible in the current frame are put at the end of the list by
;; default).  At any time I can select the item at the head of the
;; list by pressing RET.  I can also put the first element at the end
;; of the list by pressing C-s, or put the last element at the head of
;; the list by pressing C-r.  The item in [] indicates what can be
;; added to my input by pressing TAB.  In this case, I will get "3"
;; added to my input.  So, press TAB:
;;	 iswitch 23{123456,123}
;;
;; At this point, I still have two matching buffers.
;; If I want the first buffer in the list, I simply press RET.  If I
;; wanted the second in the list, I could press C-s to move it to the
;; top of the list and then RET to select it.
;;
;; However, if I type 4, I only have one match left:
;;       iswitch 234[123456] [Matched]
;;
;; Since there is only one matching buffer left, it is given in [] and we
;; see the text [Matched] afterwards.  I can now press TAB or RET to go
;; to that buffer.
;;
;; If however, I now type "a":
;;       iswitch 234a [No match]
;; There are no matching buffers.  If I press RET or TAB, I can be
;; prompted to create a new buffer called "234a".
;;
;; Of course, where this function comes in really useful is when you
;; can specify the buffer using only a few keystrokes.  In the above
;; example, the quickest way to get to the "123456" buffer would be
;; just to type 4 and then RET (assuming there isn't any newer buffer
;; with 4 in its name).

;; To see a full list of all matching buffers in a separate buffer,
;; hit ? or press TAB when there are no further completions to the
;; substring.  Repeated TAB presses will scroll you through this
;; separate buffer.

;; The buffer at the head of the list can be killed by pressing C-k.
;; If the buffer needs saving, you will be queried before the buffer
;; is killed.

;; If you find that the file you are after is not in a buffer, you can
;; press C-x C-f to immediately drop into find-file.

;; See the doc string of freekbs2-es for full keybindings and features.
;; (describe-function 'freekbs2-es)

;; Case matching: The case of strings when matching can be ignored or
;; used depending on the value of freekbs2-es-case (default is the same
;; as case-fold-search, normally t).  Imagine you have the following
;; buffers:
;;
;; INBOX *info* *scratch*
;;
;; Then these will be the matching buffers, depending on how you type
;; the two letters `in' and the value of freekbs2-es-case:
;;
;; freekbs2-es-case   user input  | matching buffers
;; ----------------------------------------------
;; nil             in          | *info*
;; t               in          | INBOX, *info*
;; t               IN          | INBOX
;; t               In          | [No match]

;;; Customisation

;; See the User Variables section below for easy ways to change the
;; functionality of the program.  These are accessible using the
;; custom package.
;; To modify the keybindings, use something like:
;;
;;(add-hook 'freekbs2-es-mode-hook 'freekbs2-es-my-keys)
;;(defun freekbs2-es-my-keys ()
;;  "Add my keybindings for freekbs2-es."
;;  (define-key freekbs2-es-mode-map " " 'freekbs2-es-next-match))
;;
;; Seeing all the matching buffers
;;
;; If you have many matching buffers, they may not all fit onto one
;; line of the minibuffer.  In Emacs 21, the variable
;; `resize-mini-windows' controls how many lines of the minibuffer can
;; be seen.  For older versions of emacs, you can use
;; `resize-minibuffer-mode'.  You can also limit freekbs2-es so that it
;; only shows a certain number of lines -- see the documentation for
;; `freekbs2-es-minibuffer-setup-hook'.

;; Changing the list of buffers

;; By default, the list of current buffers is most recent first,
;; oldest last, with the exception that the buffers visible in the
;; current frame are put at the end of the list.  A hook exists to
;; allow other functions to order the list.  For example, if you add:
;;
;; (add-hook 'freekbs2-es-make-buflist-hook 'freekbs2-es-summaries-to-end)
;;
;; then all buffers matching "Summary" are moved to the end of the
;; list.  (I find this handy for keeping the INBOX Summary and so on
;; out of the way.)  It also moves buffers matching "output\*$" to the
;; end of the list (these are created by AUCTeX when compiling.)
;; Other functions could be made available which alter the list of
;; matching buffers (either deleting or rearranging elements.)

;; Font-Lock

;; font-lock is used to highlight the first matching buffer.  To
;; switch this off, set (setq freekbs2-es-use-faces nil).  Colouring of
;; the matching buffer name was suggested by Carsten Dominik
;; (dominik@strw.leidenuniv.nl)

;; Replacement for read-buffer

;; freekbs2-es-read-buffer has been written to be a drop in replacement
;; for the normal buffer selection routine `read-buffer'.  To use
;; iswitch for all buffer selections in Emacs, add:
;; (setq read-buffer-function 'freekbs2-es-read-buffer)
;; (This variable was introduced in Emacs 20.3.)
;; XEmacs users can get the same behaviour by doing:
;; (defalias 'read-buffer 'freekbs2-es-read-buffer)
;; since `read-buffer' is defined in lisp.

;; Using freekbs2-es for other completion tasks.

;; Kin Cho (kin@neoscale.com) sent the following suggestion to use
;; freekbs2-es for other completion tasks.
;;
;; (defun my-icompleting-read (prompt choices)
;;   "Use iswitch as a completing-read replacement to choose from
;; choices.  PROMPT is a string to prompt with.  CHOICES is a list of
;; strings to choose from."
;;   (let ((freekbs2-es-make-buflist-hook
;;          (lambda ()
;;            (setq freekbs2-es-temp-buflist choices))))
;;     (freekbs2-es-read-buffer prompt)))
;;
;; example:
;; (my-icompleting-read "Which fruit? " '
;; 		     ("apple" "pineapple" "pear" "bananas" "oranges") )

;; Kin Cho also suggested the following defun.  Once you have a subset of
;; matching buffers matching your current prompt, you can then press
;; e.g. C-o to restrict matching to those buffers and clearing the prompt:
;; (defun freekbs2-es-exclude-nonmatching()
;;    "Make freekbs2-es work on only the currently matching names."
;;    (interactive)
;;    (setq freekbs2-es-buflist freekbs2-es-matches)
;;    (setq freekbs2-es-rescan t)
;;    (delete-minibuffer-contents))
;;
;; (add-hook 'freekbs2-es-define-mode-map-hook
;; 	  '(lambda () (define-key
;; 			freekbs2-es-mode-map "\C-o"
;; 			'freekbs2-es-exclude-nonmatching)))

;; Other lisp packages extend freekbs2-es behaviour to other tasks.  See
;; ido.el (by Kim Storm) and mcomplete.el (Yuji Minejima).

;; Window managers: Switching frames/focus follows mouse; Sawfish.

;; If you switch to a buffer that is visible in another frame,
;; freekbs2-es can switch focus to that frame.  If your window manager
;; uses "click to focus" policy for window selection, you should also
;; set focus-follows-mouse to nil.

;; iswitch functionality has also been implemented for switching
;; between windows in the Sawfish window manager.

;; Regexp matching

;; There is provision for regexp matching within freekbs2-es, enabled
;; through `freekbs2-es-regexp'.  This allows you to type `c$' for
;; example and see all buffer names ending in `c'.  No completion
;; mechanism is currently offered when regexp searching.

;;; TODO

;;; Acknowledgements

;; Thanks to Jari Aalto <jari.aalto@poboxes.com> for help with the
;; first version of this package, iswitch-buffer.  Thanks also to many
;; others for testing earlier versions.

;;; Code:

;; CL needed for cadr and last
(if (not (and (fboundp 'cadr)
	      (fboundp 'last)))
    (require 'cl))

(require 'font-lock)

;; Set up the custom library.
;; taken from http://www.dina.kvl.dk/~abraham/custom/
(eval-and-compile
  (condition-case ()
      (require 'custom)
    (error nil))
  (if (and (featurep 'custom) (fboundp 'custom-declare-variable))
      nil ;; We've got what we needed
    ;; We have the old custom-library, hack around it!
    (defmacro defgroup (&rest args)
      nil)
    (defmacro defcustom (var value doc &rest args)
      `(defvar ,var ,value ,doc))))

;;; User Variables
;;
;; These are some things you might want to change.

(defgroup freekbs2-es nil
  "Switch between buffers using substrings."
  :group 'convenience
  :group 'completion
  :link '(emacs-commentary-link :tag "Commentary" "freekbs2-es.el")
  :link '(url-link "http://www.anc.ed.ac.uk/~stephen/emacs/")
  :link '(emacs-library-link :tag "Lisp File" "freekbs2-es.el"))

(defcustom freekbs2-es-case case-fold-search
  "*Non-nil if searching of buffer names should ignore case.
If this is non-nil but the user input has any upper case letters, matching
is temporarily case sensitive."
  :type 'boolean
  :group 'freekbs2-es)

(defcustom freekbs2-es-buffer-ignore
  '("^ ")
  "*List of regexps or functions matching buffer names to ignore.
For example, traditional behavior is not to list buffers whose names begin
with a space, for which the regexp is `^ '.  See the source file for
example functions that filter buffer names."
  :type '(repeat (choice regexp function))
  :group 'freekbs2-es)
(put 'freekbs2-es-buffer-ignore 'risky-local-variable t)

(defcustom freekbs2-es-max-to-show nil
  "*If non-nil, limit the number of names shown in the minibuffer.
If this value is N, and N is greater than the number of matching
buffers, the first N/2 and the last N/2 matching buffers are
shown.  This can greatly speed up freekbs2-es if you have a
multitude of buffers open."
  :type '(choice (const :tag "Show all" nil) integer)
  :group 'freekbs2-es)

(defcustom freekbs2-es-use-virtual-buffers nil
  "*If non-nil, refer to past buffers when none match.
This feature relies upon the `recentf' package, which will be
enabled if this variable is configured to a non-nil value."
  :type 'boolean
  :require 'recentf
  :set (function
	(lambda (sym value)
	  (if value (recentf-mode 1))
	  (set sym value)))
  :group 'freekbs2-es)

(defvar freekbs2-es-virtual-buffers nil)

(defcustom freekbs2-es-cannot-complete-hook 'freekbs2-es-completion-help
  "*Hook run when `freekbs2-es-complete' can't complete any more.
The most useful values are `freekbs2-es-completion-help', which pops up a
window with completion alternatives, or `freekbs2-es-next-match' or
`freekbs2-es-prev-match', which cycle the buffer list."
  :type 'hook
  :group 'freekbs2-es)

;;; Examples for setting the value of freekbs2-es-buffer-ignore
;(defun freekbs2-es-ignore-c-mode (name)
;  "Ignore all c mode buffers -- example function for freekbs2-es."
;  (save-excursion
;    (set-buffer name)
;    (string-match "^C$" mode-name)))

;(setq freekbs2-es-buffer-ignore '("^ " freekbs2-es-ignore-c-mode))
;(setq freekbs2-es-buffer-ignore '("^ " "\\.c$" "\\.h$"))

(defcustom freekbs2-es-default-method  'always-frame
    "*How to switch to new buffer when using `freekbs2-es-buffer'.
Possible values:
`samewindow'	Show new buffer in same window
`otherwindow'	Show new buffer in another window (same frame)
`display'	Display buffer in another window without switching to it
`otherframe'	Show new buffer in another frame
`maybe-frame'	If a buffer is visible in another frame, prompt to ask if you
		you want to see the buffer in the same window of the current
  		frame or in the other frame.
`always-frame'  If a buffer is visible in another frame, raise that
		frame.  Otherwise, visit the buffer in the same window."
    :type '(choice (const samewindow)
		   (const otherwindow)
		   (const display)
		   (const otherframe)
		   (const maybe-frame)
		   (const always-frame))
    :group 'freekbs2-es)

(defcustom freekbs2-es-regexp nil
  "*Non-nil means that `freekbs2-es' will do regexp matching.
Value can be toggled within `freekbs2-es' using `freekbs2-es-toggle-regexp'."
  :type 'boolean
  :group 'freekbs2-es)

(defcustom freekbs2-es-newbuffer t
  "*Non-nil means create new buffer if no buffer matches substring.
See also `freekbs2-es-prompt-newbuffer'."
  :type 'boolean
  :group 'freekbs2-es)

(defcustom freekbs2-es-prompt-newbuffer t
  "*Non-nil means prompt user to confirm before creating new buffer.
See also `freekbs2-es-newbuffer'."
  :type 'boolean
  :group 'freekbs2-es)

(defcustom freekbs2-es-use-faces t
  "*Non-nil means use font-lock faces for showing first match."
  :type 'boolean
  :group 'freekbs2-es)
(define-obsolete-variable-alias 'freekbs2-es-use-fonts 'freekbs2-es-use-faces "22.1")

(defcustom freekbs2-es-use-frame-buffer-list nil
  "*Non-nil means use the currently selected frame's buffer list."
  :type 'boolean
  :group 'freekbs2-es)

(defcustom freekbs2-es-make-buflist-hook  nil
  "Hook to run when list of matching buffers is created."
  :type 'hook
  :group 'freekbs2-es)

(defvar freekbs2-es-all-frames 'visible
  "*Argument to pass to `walk-windows' when finding visible buffers.
See documentation of `walk-windows' for useful values.")

(defcustom freekbs2-es-minibuffer-setup-hook nil
  "Freekbs2-Es-specific customization of minibuffer setup.

This hook is run during minibuffer setup if `freekbs2-es' is active.
For instance:
\(add-hook 'freekbs2-es-minibuffer-setup-hook
	  '\(lambda () (set (make-local-variable 'max-mini-window-height) 3)))
will constrain the minibuffer to a maximum height of 3 lines when
freekbs2-es is running."
  :type 'hook
  :group 'freekbs2-es)

(defface freekbs2-es-single-match
  '((t
     (:inherit font-lock-comment-face)))
  "Freekbs2-Es face for single matching buffer name."
  :version "22.1"
  :group 'freekbs2-es)

(defface freekbs2-es-current-match
  '((t
     (:inherit font-lock-function-name-face)))
  "Freekbs2-Es face for current matching buffer name."
  :version "22.1"
  :group 'freekbs2-es)

(defface freekbs2-es-virtual-matches
  '((t
     (:inherit font-lock-builtin-face)))
  "Freekbs2-Es face for matching virtual buffer names.
See also `freekbs2-es-use-virtual-buffers'."
  :version "22.1"
  :group 'freekbs2-es)

(defface freekbs2-es-invalid-regexp
  '((t
     (:inherit font-lock-warning-face)))
  "Freekbs2-Es face for indicating invalid regexp. "
  :version "22.1"
  :group 'freekbs2-es)

;; Do we need the variable freekbs2-es-use-mycompletion?

;;; Internal Variables

(defvar freekbs2-es-method nil
  "Stores the method for viewing the selected buffer.
Its value is one of `samewindow', `otherwindow', `display', `otherframe',
`maybe-frame' or `always-frame'.  See `freekbs2-es-default-method' for
details of values.")

(defvar freekbs2-es-eoinput 1
  "Point where minibuffer input ends and completion info begins.
Copied from `icomplete-eoinput'.")
(make-variable-buffer-local 'freekbs2-es-eoinput)

(defvar freekbs2-es-buflist nil
  "Stores the current list of buffers that will be searched through.
The list is ordered, so that the most recent buffers come first,
although by default, the buffers visible in the current frame are put
at the end of the list.  Created by `freekbs2-es-make-buflist'.")

;; todo -- is this necessary?

(defvar freekbs2-es-use-mycompletion nil
  "Non-nil means use `freekbs2-es-buffer' completion feedback.
Should only be set to t by freekbs2-es functions, so that it doesn't
interfere with other minibuffer usage.")

(defvar freekbs2-es-change-word-sub nil
  "Private variable used by `freekbs2-es-word-matching-substring'.")

(defvar freekbs2-es-common-match-string  nil
  "Stores the string that is common to all matching buffers.")

(defvar freekbs2-es-rescan nil
  "Non-nil means we need to regenerate the list of matching buffers.")

(defvar freekbs2-es-text nil
  "Stores the users string as it is typed in.")

(defvar freekbs2-es-matches nil
  "List of buffers currently matching `freekbs2-es-text'.")

(defvar freekbs2-es-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map minibuffer-local-map)
    (define-key map "?" 'freekbs2-es-completion-help)
    (define-key map "\C-s" 'freekbs2-es-next-match)
    (define-key map "\C-r" 'freekbs2-es-prev-match)
    (define-key map "\t" 'freekbs2-es-complete)
    (define-key map "\C-j" 'freekbs2-es-select-buffer-text)
    (define-key map "\C-t" 'freekbs2-es-toggle-regexp)
    (define-key map "\C-x\C-f" 'freekbs2-es-find-file)
    (define-key map "\C-c" 'freekbs2-es-toggle-case)
    (define-key map "\C-k" 'freekbs2-es-kill-buffer)
    (define-key map "\C-m" 'freekbs2-es-exit-minibuffer)
    map)
  "Minibuffer keymap for `freekbs2-es-buffer'.")

(defvar freekbs2-es-global-map
  (let ((map (make-sparse-keymap)))
;;     (dolist (b '((switch-to-buffer . freekbs2-es-buffer)
;;                  (switch-to-buffer-other-window . freekbs2-es-buffer-other-window)
;;                  (switch-to-buffer-other-frame . freekbs2-es-buffer-other-frame)
;;                  (display-buffer . freekbs2-es-display-buffer)))
;;       (if (fboundp 'command-remapping)
;;           (define-key map (vector 'remap (car b)) (cdr b))
;;         (substitute-key-definition (car b) (cdr b) map global-map)))
    map)
  "Global keymap for `freekbs2-es-mode'.")

(defvar freekbs2-es-history nil
  "History of buffers selected using `freekbs2-es-buffer'.")

(defvar freekbs2-es-exit nil
  "Flag to monitor how `freekbs2-es-buffer' exits.
If equal to `takeprompt', we use the prompt as the buffer name to be
selected.")

(defvar freekbs2-es-buffer-ignore-orig nil
  "Stores original value of `freekbs2-es-buffer-ignore'.")

(defvar freekbs2-es-default nil
  "Default buffer for freekbs2-es.")

;; The following variables are needed to keep the byte compiler quiet.
(defvar freekbs2-es-require-match nil
  "Non-nil if matching buffer must be selected.")

(defvar freekbs2-es-temp-buflist nil
  "Stores a temporary version of the buffer list being created.")

(defvar freekbs2-es-bufs-in-frame nil
  "List of the buffers visible in the current frame.")

(defvar freekbs2-es-minibuf-depth nil
  "Value we expect to be returned by `minibuffer-depth' in the minibuffer.")

(defvar freekbs2-es-common-match-inserted nil
  "Non-nil if we have just inserted a common match in the minibuffer.")

(defvar freekbs2-es-invalid-regexp)

;;; FUNCTIONS

;;; FREEKBS2-ES KEYMAP
(defun freekbs2-es-define-mode-map ()
  "Set up the keymap for `freekbs2-es-buffer'.
This is obsolete.  Use \\[freekbs2-es-mode] or customize the
variable `freekbs2-es-mode'."
  (interactive)
  (let (map)
    ;; generated every time so that it can inherit new functions.
    ;;(or freekbs2-es-mode-map

    (setq map (copy-keymap minibuffer-local-map))
    (define-key map "?" 'freekbs2-es-completion-help)
    (define-key map "\C-s" 'freekbs2-es-next-match)
    (define-key map "\C-r" 'freekbs2-es-prev-match)
    (define-key map "\t" 'freekbs2-es-complete)
    (define-key map "\C-j" 'freekbs2-es-select-buffer-text)
    (define-key map "\C-t" 'freekbs2-es-toggle-regexp)
    (define-key map "\C-x\C-f" 'freekbs2-es-find-file)
    (define-key map "\C-n" 'freekbs2-es-toggle-ignore)
    (define-key map "\C-c" 'freekbs2-es-toggle-case)
    (define-key map "\C-k" 'freekbs2-es-kill-buffer)
    (define-key map "\C-m" 'freekbs2-es-exit-minibuffer)
    (setq freekbs2-es-mode-map map)
    (run-hooks 'freekbs2-es-define-mode-map-hook)))

;;; MAIN FUNCTION
(defun freekbs2-es ()
  "Switch to buffer matching a substring.
As you type in a string, all of the buffers matching the string are
displayed.  When you have found the buffer you want, it can then be
selected.  As you type, most keys have their normal keybindings,
except for the following:
\\<freekbs2-es-mode-map>

RET Select the buffer at the front of the list of matches.  If the
list is empty, possibly prompt to create new buffer.

\\[freekbs2-es-select-buffer-text] Select the current prompt as the buffer.
If no buffer is found, prompt for a new one.

\\[freekbs2-es-next-match] Put the first element at the end of the list.
\\[freekbs2-es-prev-match] Put the last element at the start of the list.
\\[freekbs2-es-complete] Complete a common suffix to the current string that
matches all buffers.  If there is only one match, select that buffer.
If there is no common suffix, show a list of all matching buffers
in a separate window.
\\[freekbs2-es-toggle-regexp] Toggle regexp searching.
\\[freekbs2-es-toggle-case] Toggle case-sensitive searching of buffer names.
\\[freekbs2-es-completion-help] Show list of matching buffers in separate window.
\\[freekbs2-es-find-file] Exit freekbs2-es and drop into `find-file'.
\\[freekbs2-es-kill-buffer] Kill buffer at head of buffer list."
  ;;\\[freekbs2-es-toggle-ignore] Toggle ignoring certain buffers (see \
  ;;`freekbs2-es-buffer-ignore')

  (let* ((prompt "UniLang entries: ")
         freekbs2-es-invalid-regexp
	 (buf (freekbs2-es-read-buffer prompt)))

    ;;(message "chosen text %s" freekbs2-es-final-text)
    ;; Choose the buffer name: either the text typed in, or the head
    ;; of the list of matches

    (cond ( (eq freekbs2-es-exit 'findfile)
	    (call-interactively 'find-file))
          (freekbs2-es-invalid-regexp
           (message "Won't make invalid regexp named buffer"))
	  (t
	   ;; View the buffer
	   ;;(message "go to buf %s" buf)
	   ;; Check buf is non-nil.
	   (if buf
	    (if nil
	     (if (get-buffer buf)
		   ;; buffer exists, so view it and then exit
		   (freekbs2-es-visit-buffer buf)
		 ;; else buffer doesn't exist
		 (freekbs2-es-possible-new-buffer buf))
	     )
	     (freekbs2-push-onto-stack (assoc buf freekbs2-es-entries-alist) nil)
	    )
	   ))))

(defun freekbs2-es-read-buffer (prompt &optional default require-match
				    start matches-set)
  "Replacement for the built-in `read-buffer'.
Return the name of a buffer selected.
PROMPT is the prompt to give to the user.
DEFAULT if given is the default buffer to be selected, which will
go to the front of the list.
If REQUIRE-MATCH is non-nil, an existing buffer must be selected.
If START is a string, the selection process is started with that
string.
If MATCHES-SET is non-nil, the buflist is not updated before
the selection process begins.  Used by isearchb.el."
  (let
      (
       buf-sel
       freekbs2-es-final-text
       (icomplete-mode nil) ;; prevent icomplete starting up
       )

    (freekbs2-es-define-mode-map)
    (setq freekbs2-es-exit nil)
    (setq freekbs2-es-default
	  (if (bufferp default)
	      (buffer-name default)
	    default))
    (setq freekbs2-es-text (or start ""))
    (unless matches-set
      (setq freekbs2-es-rescan t)
      (freekbs2-es-make-buflist freekbs2-es-default)
      (freekbs2-es-set-matches))
    (let
	((minibuffer-local-completion-map freekbs2-es-mode-map)
	 ;; Record the minibuffer depth that we expect to find once
	 ;; the minibuffer is set up and freekbs2-es-entryfn-p is called.
	 (freekbs2-es-minibuf-depth (1+ (minibuffer-depth)))
	 (freekbs2-es-require-match require-match))
      ;; prompt the user for the buffer name
      (setq freekbs2-es-final-text (completing-read
				 prompt		  ;the prompt
				 '(("dummy" . 1)) ;table
				 nil		  ;predicate
				 nil ;require-match [handled elsewhere]
				 start	;initial-contents
				 'freekbs2-es-history)))
    (if (and (not (eq freekbs2-es-exit 'usefirst))
	     (car freekbs2-es-final-text))
	;; This happens for example if the buffer was chosen with the mouse.
	(setq freekbs2-es-matches (list freekbs2-es-final-text)
	      freekbs2-es-virtual-buffers nil))

    ;; If no buffer matched, but a virtual buffer was selected, visit
    ;; that file now and act as though that buffer had been selected.
    (if (and freekbs2-es-virtual-buffers
	     (not (freekbs2-es-existing-buffer-p)))
	(let ((virt (car freekbs2-es-virtual-buffers)))
	  (find-file-noselect (cdr virt))
	  (setq freekbs2-es-matches (list (car virt))
		freekbs2-es-virtual-buffers nil)))

    ;; Handling the require-match must be done in a better way.
    (if (and require-match
	     (not (freekbs2-es-existing-buffer-p)))
	(error "Must specify valid buffer"))

    (if (or (eq freekbs2-es-exit 'takeprompt)
	    (null freekbs2-es-matches))
	(setq buf-sel freekbs2-es-final-text)
      ;; else take head of list
      (setq buf-sel (car freekbs2-es-matches)))

    ;; Or possibly choose the default buffer
    (if  (equal freekbs2-es-final-text "")
	(setq buf-sel (car freekbs2-es-matches)))

    buf-sel))

(defun freekbs2-es-existing-buffer-p ()
  "Return non-nil if there is a matching buffer."
  (not (null freekbs2-es-matches)))

;;; COMPLETION CODE

(defun freekbs2-es-set-common-completion  ()
  "Find common completion of `freekbs2-es-text' in `freekbs2-es-matches'.
The result is stored in `freekbs2-es-common-match-string'."

  (let* (val)
    (setq  freekbs2-es-common-match-string nil)
    (if (and freekbs2-es-matches
	     (not freekbs2-es-regexp) ;; testing
             (stringp freekbs2-es-text)
             (> (length freekbs2-es-text) 0))
        (if (setq val (freekbs2-es-find-common-substring
                       freekbs2-es-matches freekbs2-es-text))
            (setq freekbs2-es-common-match-string val)))
    val))

(defun freekbs2-es-complete ()
  "Try and complete the current pattern amongst the buffer names."
  (interactive)
  (let (res)
    (cond ((not  freekbs2-es-matches)
	   (run-hooks 'freekbs2-es-cannot-complete-hook))
          (freekbs2-es-invalid-regexp
           ;; Do nothing
           )
	  ((= 1 (length freekbs2-es-matches))
	   ;; only one choice, so select it.
	   (exit-minibuffer))

	  (t
	   ;; else there could be some completions
	   (setq res freekbs2-es-common-match-string)
	   (if (and (not (memq res '(t nil)))
		    (not (equal res freekbs2-es-text)))
	       ;; found something to complete, so put it in the minibuffer.
	       (progn
		 (setq freekbs2-es-rescan nil
                       freekbs2-es-common-match-inserted t)
		 (delete-region (minibuffer-prompt-end) (point))
		 (insert  res))
	     ;; else nothing to complete
	     (run-hooks 'freekbs2-es-cannot-complete-hook)
	     )))))

;;; TOGGLE FUNCTIONS

(defun freekbs2-es-toggle-case ()
  "Toggle the value of variable `freekbs2-es-case'."
  (interactive)
  (setq freekbs2-es-case (not freekbs2-es-case))
  ;; ask for list to be regenerated.
  (setq freekbs2-es-rescan t))

(defun freekbs2-es-toggle-regexp ()
  "Toggle the value of `freekbs2-es-regexp'."
  (interactive)
  (setq freekbs2-es-regexp (not freekbs2-es-regexp))
  ;; ask for list to be regenerated.
  (setq freekbs2-es-rescan t))

(defun freekbs2-es-toggle-ignore ()
  "Toggle ignoring buffers specified with `freekbs2-es-buffer-ignore'."
  (interactive)
  (if freekbs2-es-buffer-ignore
      (progn
        (setq freekbs2-es-buffer-ignore-orig freekbs2-es-buffer-ignore)
        (setq freekbs2-es-buffer-ignore nil))
    ;; else
    (setq freekbs2-es-buffer-ignore freekbs2-es-buffer-ignore-orig))
  (freekbs2-es-make-buflist freekbs2-es-default)
  ;; ask for list to be regenerated.
  (setq freekbs2-es-rescan t))

(defun freekbs2-es-exit-minibuffer ()
  "Exit minibuffer, but make sure we have a match if one is needed."
  (interactive)
  (if (or (not freekbs2-es-require-match)
	   (freekbs2-es-existing-buffer-p))
      (progn
	(setq freekbs2-es-exit 'usefirst)
	(throw 'exit nil))))

(defun freekbs2-es-select-buffer-text ()
  "Select the buffer named by the prompt.
If no buffer exactly matching the prompt exists, maybe create a new one."
  (interactive)
  (setq freekbs2-es-exit 'takeprompt)
  (exit-minibuffer))

(defun freekbs2-es-find-file ()
  "Drop into `find-file' from buffer switching."
  (interactive)
  (setq freekbs2-es-exit 'findfile)
  (exit-minibuffer))

(eval-when-compile
  (defvar recentf-list))

(defun freekbs2-es-next-match ()
  "Put first element of `freekbs2-es-matches' at the end of the list."
  (interactive)
  (let ((next  (cadr freekbs2-es-matches)))
    (if (and (null next) freekbs2-es-virtual-buffers)
	(setq recentf-list
	      (freekbs2-es-chop recentf-list
			     (cdr (cadr freekbs2-es-virtual-buffers))))
      (setq freekbs2-es-buflist (freekbs2-es-chop freekbs2-es-buflist next)))
    (setq freekbs2-es-rescan t)))

(defun freekbs2-es-prev-match ()
  "Put last element of `freekbs2-es-matches' at the front of the list."
  (interactive)
  (let ((prev  (car (last freekbs2-es-matches))))
    (if (and (null prev) freekbs2-es-virtual-buffers)
	(setq recentf-list
	      (freekbs2-es-chop recentf-list
			     (cdr (car (last freekbs2-es-virtual-buffers)))))
      (setq freekbs2-es-buflist (freekbs2-es-chop freekbs2-es-buflist prev)))
    (setq freekbs2-es-rescan t)))

(defun freekbs2-es-chop (list elem)
  "Remove all elements before ELEM and put them at the end of LIST."
  (let ((ret nil)
	(next nil)
	(sofar nil))
    (while (not ret)
      (setq next (car list))
      (if (equal next elem)
	  (setq ret (append list (nreverse sofar)))
	;; else
	(progn
	  (setq list (cdr list))
	  (setq sofar (cons next sofar)))))
    ret))

;;; CREATE LIST OF ALL CURRENT BUFFERS


(defun freekbs2-es-get-entries ()
 "Load entries from UniLang into Emacs for tab completion"
 (message "Load entries from UniLang into Emacs for tab completion (could take a WHILE)...")
 (let ((text (concat "'" (shell-command-to-string "/var/lib/myfrdcsa/codebases/internal/freekbs2/scripts/fes-get-entries.pl"))))
  (eval (read text))))

(defun freekbs2-es-make-buflist (default)
 (if (or
      (not (boundp 'freekbs2-es-buflist))
      (eq freekbs2-es-buflist nil))
  (progn
   (setq freekbs2-es-entries-alist
    (freekbs2-es-get-entries))
   (setq freekbs2-es-buflist 
    freekbs2-es-entries-alist))
  ))

;; (defun freekbs2-es-make-buflist (default)
;;   "Set `freekbs2-es-buflist' to the current list of buffers.
;; Currently visible buffers are put at the end of the list.
;; The hook `freekbs2-es-make-buflist-hook' is run after the list has been
;; created to allow the user to further modify the order of the buffer names
;; in this list.  If DEFAULT is non-nil, and corresponds to an existing buffer,
;; it is put to the start of the list."
;;   (setq freekbs2-es-buflist
;; 	(let* ((freekbs2-es-current-buffers (freekbs2-es-get-buffers-in-frames))
;; 	       (freekbs2-es-temp-buflist
;; 		(delq nil
;; 		      (mapcar
;; 		       (lambda (x)
;; 			 (let ((b-name (buffer-name x)))
;; 			   (if (not
;; 				(or
;; 				 (freekbs2-es-ignore-buffername-p b-name)
;; 				 (memq b-name freekbs2-es-current-buffers)))
;; 			       b-name)))
;; 		       (buffer-list (and freekbs2-es-use-frame-buffer-list
;; 					 (selected-frame)))))))
;; 	  (setq freekbs2-es-temp-buflist
;; 		(nconc freekbs2-es-temp-buflist freekbs2-es-current-buffers))
;; 	  (run-hooks 'freekbs2-es-make-buflist-hook)
;; 	 ;; Should this be after the hooks, or should the hooks be the
;; 	  ;; final thing to be run?
;; 	  (if default
;; 	      (progn
;; 		(setq freekbs2-es-temp-buflist
;; 		      (delete default freekbs2-es-temp-buflist))
;; 		(setq freekbs2-es-temp-buflist
;; 		      (cons default freekbs2-es-temp-buflist))))
;; 	  freekbs2-es-temp-buflist)))

(defun freekbs2-es-to-end (lst)
  "Move the elements from LST to the end of `freekbs2-es-temp-buflist'."
  (dolist (elem lst)
    (setq freekbs2-es-temp-buflist (delq elem freekbs2-es-temp-buflist)))
  (setq freekbs2-es-temp-buflist (nconc freekbs2-es-temp-buflist lst)))

(defun freekbs2-es-get-buffers-in-frames (&optional current)
  "Return the list of buffers that are visible in the current frame.
If optional argument CURRENT is given, restrict searching to the
current frame, rather than all frames, regardless of value of
`freekbs2-es-all-frames'."
  (let ((freekbs2-es-bufs-in-frame nil))
    (walk-windows 'freekbs2-es-get-bufname nil
		  (if current
		      nil
		    freekbs2-es-all-frames))
    freekbs2-es-bufs-in-frame))

(defun freekbs2-es-get-bufname (win)
  "Used by `freekbs2-es-get-buffers-in-frames' to walk through all windows."
  (let ((buf (buffer-name (window-buffer win))))
	(if (not (member buf freekbs2-es-bufs-in-frame))
	    ;; Only add buf if it is not already in list.
	    ;; This prevents same buf in two different windows being
	    ;; put into the list twice.
	    (setq freekbs2-es-bufs-in-frame
		  (cons buf freekbs2-es-bufs-in-frame)))))

;;; FIND MATCHING BUFFERS

(defun freekbs2-es-set-matches ()
  "Set `freekbs2-es-matches' to the list of buffers matching prompt."
  (if freekbs2-es-rescan
      (setq freekbs2-es-matches
	    (let* ((buflist freekbs2-es-buflist))
	      (freekbs2-es-get-matched-buffers freekbs2-es-text freekbs2-es-regexp
					    buflist))
	    freekbs2-es-virtual-buffers nil)))

(defun freekbs2-es-get-matched-buffers (regexp
				     &optional string-format buffer-list)
  "Return buffers matching REGEXP.
If STRING-FORMAT is nil, consider REGEXP as just a string.
BUFFER-LIST can be list of buffers or list of strings."
  (let* ((case-fold-search (freekbs2-es-case))
         name ret)
    (if (null string-format) (setq regexp (regexp-quote regexp)))
    (setq freekbs2-es-invalid-regexp nil)
    (condition-case error
        (dolist (x buffer-list (nreverse ret))
          (setq name (if (stringp x) x (car x)))
          (when (and (string-match regexp name)
                     (not (freekbs2-es-ignore-buffername-p name)))
            (push name ret)))
      (invalid-regexp
       (setq freekbs2-es-invalid-regexp t)
       (cdr error)))))

(defun freekbs2-es-ignore-buffername-p (bufname)
  "Return t if the buffer BUFNAME should be ignored."
  (let ((data       (match-data))
        (re-list    freekbs2-es-buffer-ignore)
        ignorep
        nextstr)
    (while re-list
      (setq nextstr (car re-list))
      (cond
       ((stringp nextstr)
        (if (string-match nextstr bufname)
            (progn
              (setq ignorep t)
              (setq re-list nil))))
       ((functionp nextstr)
        (if (funcall nextstr bufname)
            (progn
              (setq ignorep t)
              (setq re-list nil)))))
      (setq re-list (cdr re-list)))
    (set-match-data data)

    ;; return the result
    ignorep))

(defun freekbs2-es-word-matching-substring (word)
  "Return part of WORD before 1st match to `freekbs2-es-change-word-sub'.
If `freekbs2-es-change-word-sub' cannot be found in WORD, return nil."
  (let ((case-fold-search (freekbs2-es-case)))
    (let ((m (string-match freekbs2-es-change-word-sub word)))
      (if m
          (substring word m)
        ;; else no match
        nil))))

(defun freekbs2-es-find-common-substring (lis subs)
  "Return common string following SUBS in each element of LIS."
  (let (res
        alist
        freekbs2-es-change-word-sub)
    (setq freekbs2-es-change-word-sub
          (if freekbs2-es-regexp
              subs
            (regexp-quote subs)))
    (setq res (mapcar 'freekbs2-es-word-matching-substring lis))
    (setq res (delq nil res)) ;; remove any nil elements (shouldn't happen)
    (setq alist (mapcar 'freekbs2-es-makealist res)) ;; could use an  OBARRAY

    ;; try-completion returns t if there is an exact match.
    (let ((completion-ignore-case (freekbs2-es-case)))

    (try-completion subs alist))))

(defun freekbs2-es-makealist (res)
  "Return dotted pair (RES . 1)."
  (cons res 1))

;; from Wayne Mesard <wmesard@esd.sgi.com>
(defun freekbs2-es-rotate-list (lis)
  "Destructively remove the last element from LIS.
Return the modified list with the last element prepended to it."
  (if (<= (length lis) 1)
      lis
    (let ((las lis)
          (prev lis))
      (while (consp (cdr las))
        (setq prev las
              las (cdr las)))
      (setcdr prev nil)
      (cons (car las) lis))))

(defun freekbs2-es-completion-help ()
  "Show possible completions in a *Completions* buffer."
  ;; we could allow this buffer to be used to select match, but I think
  ;; choose-completion-string will need redefining, so it just inserts
  ;; choice with out any previous input.
  (interactive)
  (setq freekbs2-es-rescan nil)
  (let ((buf (current-buffer))
	(temp-buf "*Completions*")
	(win))

    (if (and (eq last-command this-command)
             (not freekbs2-es-common-match-inserted))
	;; scroll buffer
	(progn
	  (set-buffer temp-buf)
	  (setq win (get-buffer-window temp-buf))
	  (if (pos-visible-in-window-p (point-max) win)
	      (set-window-start win (point-min))
	    (scroll-other-window))
	  (set-buffer buf))

      (with-output-to-temp-buffer temp-buf
	(if (featurep 'xemacs)

	    ;; XEmacs extents are put on by default, doesn't seem to be
	    ;; any way of switching them off.
	 (display-completion-list (if freekbs2-es-matches
					 freekbs2-es-matches
				       freekbs2-es-buflist)
				     :help-string "freekbs2-es "
				     :activate-callback
				     (lambda (x y z)
				       (message "doesn't work yet, sorry!")))
	  ;; else running Emacs
	  (with-current-buffer standard-output
	    (fundamental-mode))
	  (display-completion-list (if freekbs2-es-matches
				       freekbs2-es-matches
				     freekbs2-es-buflist))))
      (setq freekbs2-es-common-match-inserted nil))))

;;; KILL CURRENT BUFFER

(defun freekbs2-es-kill-buffer ()
  "Kill the buffer at the head of `freekbs2-es-matches'."
  (interactive)
  (let ( (enable-recursive-minibuffers t)
	 buf)

    (setq buf (car freekbs2-es-matches))
    ;; check to see if buf is non-nil.
    (if buf
	(progn
	  (kill-buffer buf)

	  ;; Check if buffer exists.  XEmacs gnuserv.el makes alias
	  ;; for kill-buffer which does not return t if buffer is
	  ;; killed, so we can't rely on kill-buffer return value.
	  (if (get-buffer buf)
	      ;; buffer couldn't be killed.
	      (setq freekbs2-es-rescan t)
	    ;; else buffer was killed so remove name from list.
	    (setq freekbs2-es-buflist  (delq buf freekbs2-es-buflist)))))))

;;; VISIT CHOSEN BUFFER
(defun freekbs2-es-visit-buffer (buffer)
  "Visit buffer named BUFFER according to `freekbs2-es-method'."
  (let* (win  newframe)
    (cond
     ((eq freekbs2-es-method 'samewindow)
      (switch-to-buffer buffer))

     ((memq freekbs2-es-method '(always-frame maybe-frame))
      (cond
       ((and (setq win (freekbs2-es-window-buffer-p buffer))
	     (or (eq freekbs2-es-method 'always-frame)
		 (y-or-n-p "Jump to frame? ")))
	(setq newframe (window-frame win))
        (if (fboundp 'select-frame-set-input-focus)
            (select-frame-set-input-focus newframe)
          (raise-frame newframe)
          (select-frame newframe)
          )
	(select-window win))
       (t
	;;  No buffer in other frames...
	(switch-to-buffer buffer)
	)))

     ((eq freekbs2-es-method 'otherwindow)
      (switch-to-buffer-other-window buffer))

     ((eq freekbs2-es-method 'display)
      (display-buffer buffer))

     ((eq freekbs2-es-method 'otherframe)
      (progn
	(switch-to-buffer-other-frame buffer)
	(if (fboundp 'select-frame-set-input-focus)
            (select-frame-set-input-focus (selected-frame)))
	)))))

(defun freekbs2-es-possible-new-buffer (buf)
  "Possibly create and visit a new buffer called BUF."

  (let ((newbufcreated))
    (if (and freekbs2-es-newbuffer
	     (or
	      (not freekbs2-es-prompt-newbuffer)

	      (and freekbs2-es-prompt-newbuffer
		   (y-or-n-p
		    (format
		     "No buffer matching `%s', create one? "
		     buf)))))
	;; then create a new buffer
	(progn
	  (setq newbufcreated (get-buffer-create buf))
	  (if (fboundp 'set-buffer-major-mode)
	      (set-buffer-major-mode newbufcreated))
	  (freekbs2-es-visit-buffer newbufcreated))
      ;; else wont create new buffer
      (message "no buffer matching `%s'" buf))))

(defun freekbs2-es-window-buffer-p  (buffer)
  "Return window pointer if BUFFER is visible in another frame.
If BUFFER is visible in the current frame, return nil."
  (interactive)
  (let ((blist (freekbs2-es-get-buffers-in-frames 'current)))
    ;;If the buffer is visible in current frame, return nil
    (if (memq buffer blist)
	nil
      ;;  maybe in other frame or icon
      (get-buffer-window buffer 0) ; better than 'visible
      )))

(defun freekbs2-es-default-keybindings ()
  "Set up default keybindings for `freekbs2-es-buffer'.
Call this function to override the normal bindings.  This function also
adds a hook to the minibuffer.

Obsolescent.  Use `freekbs2-es-mode'."
  (interactive)
  (add-hook 'minibuffer-setup-hook 'freekbs2-es-minibuffer-setup)
  (global-set-key "\C-xb" 'freekbs2-es-buffer)
  (global-set-key "\C-x4b" 'freekbs2-es-buffer-other-window)
  (global-set-key "\C-x4\C-o" 'freekbs2-es-display-buffer)
  (global-set-key "\C-x5b" 'freekbs2-es-buffer-other-frame))

(defun freekbs2-es-buffer ()
  "Switch to another buffer.

The buffer name is selected interactively by typing a substring.  The
buffer is displayed according to `freekbs2-es-default-method' -- the
default is to show it in the same window, unless it is already visible
in another frame.
For details of keybindings, do `\\[describe-function] freekbs2-es'."
  (interactive)
  (setq freekbs2-es-method freekbs2-es-default-method)
  (freekbs2-es))

(defun freekbs2-es-buffer-other-window ()
  "Switch to another buffer and show it in another window.
The buffer name is selected interactively by typing a substring.
For details of keybindings, do `\\[describe-function] freekbs2-es'."
  (interactive)
  (setq freekbs2-es-method 'otherwindow)
  (freekbs2-es))

(defun freekbs2-es-display-buffer ()
  "Display a buffer in another window but don't select it.
The buffer name is selected interactively by typing a substring.
For details of keybindings, do `\\[describe-function] freekbs2-es'."
  (interactive)
  (setq freekbs2-es-method 'display)
  (freekbs2-es))

(defun freekbs2-es-buffer-other-frame ()
  "Switch to another buffer and show it in another frame.
The buffer name is selected interactively by typing a substring.
For details of keybindings, do `\\[describe-function] freekbs2-es'."
  (interactive)
  (setq freekbs2-es-method 'otherframe)
  (freekbs2-es))

;;; XEmacs hack for showing default buffer

;; The first time we enter the minibuffer, Emacs puts up the default
;; buffer to switch to, but XEmacs doesn't -- presumably there is a
;; subtle difference in the two versions of post-command-hook.  The
;; default is shown for both whenever we delete all of our text
;; though, indicating its just a problem the first time we enter the
;; function.  To solve this, we use another entry hook for emacs to
;; show the default the first time we enter the minibuffer.

(defun freekbs2-es-init-XEmacs-trick ()
  "Display default buffer when first entering minibuffer.
This is a hack for XEmacs, and should really be handled by `freekbs2-es-exhibit'."
  (if (freekbs2-es-entryfn-p)
      (progn
	(freekbs2-es-exhibit)
	(goto-char (point-min)))))

;; add this hook for XEmacs only.
(if (featurep 'xemacs)
    (add-hook 'freekbs2-es-minibuffer-setup-hook
	      'freekbs2-es-init-XEmacs-trick))

;;; XEmacs / backspace key
;; For some reason, if the backspace key is pressed in XEmacs, the
;; line gets confused, so I've added a simple key definition to make
;; backspace act like the normal delete key.

(defun freekbs2-es-xemacs-backspacekey ()
  "Bind backspace to `backward-delete-char'."
  (define-key freekbs2-es-mode-map '[backspace] 'backward-delete-char)
  (define-key freekbs2-es-mode-map '[(meta backspace)] 'backward-kill-word))

(if (featurep 'xemacs)
    (add-hook 'freekbs2-es-define-mode-map-hook
	      'freekbs2-es-xemacs-backspacekey))

;;; ICOMPLETE TYPE CODE

(defun freekbs2-es-recent-keys-last-key ()
 ""
 (interactive)
 (car (last (mapcar (lambda (key)
		(if (or (integerp key) (symbolp key) (listp key))
		 (single-key-description key)
		 (prin1-to-string key nil)))
	(recent-keys)))))

(defun freekbs2-es-exhibit ()
 "Find matching buffers and display a list in the minibuffer.
Copied from `icomplete-exhibit' with two changes:
1. It prints a default buffer name when there is no text yet entered.
2. It calls my completion routine rather than the standard completion."
 (if freekbs2-es-use-mycompletion
  (let ((contents (buffer-substring (minibuffer-prompt-end) (point-max)))
	(buffer-undo-list t))
   (save-excursion
    (goto-char (point-max))
                                        ; Register the end of input, so we
                                        ; know where the extra stuff
                                        ; (match-status info) begins:
    (if (not (boundp 'freekbs2-es-eoinput))
     ;; In case it got wiped out by major mode business:
     (make-local-variable 'freekbs2-es-eoinput))
    (setq freekbs2-es-eoinput (point))
    ;; Update the list of matches

    (setq freekbs2-es-text contents)
    (freekbs2-es-set-matches)
    (setq freekbs2-es-rescan t)
    (freekbs2-es-set-common-completion)

    ;;     (if (string= (freekbs2-es-recent-keys-last-key) "TAB")
    ;;      (progn
    ;;       )
    ;;      )
    ;; Insert the match-status information:
    (if nil 
     (insert (freekbs2-es-completions
	      contents)))
    ))))

(eval-when-compile
  (defvar most-len)
  (defvar most-is-exact))

(defun freekbs2-es-output-completion (com)
  (if (= (length com) most-len)
      ;; Most is one exact match,
      ;; note that and leave out
      ;; for later indication:
      (ignore
       (setq most-is-exact t))
    (substring com most-len)))

(defun freekbs2-es-completions (name)
  "Return the string that is displayed after the user's text.
Modified from `icomplete-completions'."

  (let ((comps freekbs2-es-matches)
                                        ; "-determined" - only one candidate
        (open-bracket-determined "[")
        (close-bracket-determined "]")
                                        ;"-prospects" - more than one candidate
        (open-bracket-prospects "{")
        (close-bracket-prospects "}")
	first)

    (if (and freekbs2-es-use-faces comps)
	(progn
	  (setq first (car comps))
	  (setq first (format "%s" first))
	  (put-text-property 0 (length first) 'face
			     (if (= (length comps) 1)
                                 (if freekbs2-es-invalid-regexp
                                     'freekbs2-es-invalid-regexp
                                   'freekbs2-es-single-match)
			       'freekbs2-es-current-match)
			     first)
	  (setq comps  (cons first (cdr comps)))))

    ;; If no buffers matched, and virtual buffers are being used, then
    ;; consult the list of past visited files, to see if we can find
    ;; the file which the user might thought was still open.
    (when (and freekbs2-es-use-virtual-buffers (null comps)
	       recentf-list)
      (setq freekbs2-es-virtual-buffers nil)
      (let ((head recentf-list) name)
	(while head
	  (if (and (setq name (file-name-nondirectory (car head)))
		   (string-match (if freekbs2-es-regexp
				     freekbs2-es-text
				   (regexp-quote freekbs2-es-text)) name)
		   (null (get-file-buffer (car head)))
		   (not (assoc name freekbs2-es-virtual-buffers))
		   (not (freekbs2-es-ignore-buffername-p name))
		   (file-exists-p (car head)))
	      (setq freekbs2-es-virtual-buffers
		    (cons (cons name (car head))
			  freekbs2-es-virtual-buffers)))
	  (setq head (cdr head)))
	(setq freekbs2-es-virtual-buffers (nreverse freekbs2-es-virtual-buffers)
	      comps (mapcar 'car freekbs2-es-virtual-buffers))
	(let ((comp comps))
	  (while comp
	    (put-text-property 0 (length (car comp))
			       'face 'freekbs2-es-virtual-matches
			       (car comp))
	    (setq comp (cdr comp))))))

    (cond ((null comps) (format " %sNo match%s"
				open-bracket-determined
				close-bracket-determined))

	  (freekbs2-es-invalid-regexp
           (concat " " (car comps)))
          ((null (cdr comps))		;one match
	   (concat
            (if (if (not freekbs2-es-regexp)
                    (= (length name)
                       (length (car comps)))
                  (string-match name (car comps))
                  (string-equal (match-string 0 (car comps))
                                (car comps)))
                ""
              (concat open-bracket-determined
			       ;; when there is one match, show the
			       ;; matching buffer name in full
			       (car comps)
			       close-bracket-determined))
		   (if (not freekbs2-es-use-faces) " [Matched]")))
	  (t				;multiple matches
	   (if (and freekbs2-es-max-to-show
		    (> (length comps) freekbs2-es-max-to-show))
	       (setq comps
		     (append
		      (let ((res nil)
			    (comp comps)
			    (end (/ freekbs2-es-max-to-show 2)))
			(while (>= (setq end (1- end)) 0)
			  (setq res (cons (car comp) res)
				comp (cdr comp)))
			(nreverse res))
		      (list "...")
		      (nthcdr (- (length comps)
				 (/ freekbs2-es-max-to-show 2)) comps))))
	   (let* (
		  ;;(most (try-completion name candidates predicate))
		  (most nil)
		  (most-len (length most))
		  most-is-exact
		  (alternatives
		   (mapconcat (if most 'freekbs2-es-output-completion
				'identity) comps ",")))

	     (concat

	      ;; put in common completion item -- what you get by
	      ;; pressing tab
	      (if (and (stringp freekbs2-es-common-match-string)
		       (> (length freekbs2-es-common-match-string) (length name)))
		  (concat open-bracket-determined
			  (substring freekbs2-es-common-match-string
				     (length name))
			  close-bracket-determined))
	      ;; end of partial matches...

	      ;; think this bit can be ignored.
	      (and (> most-len (length name))
		   (concat open-bracket-determined
			   (substring most (length name))
			   close-bracket-determined))

	      ;; list all alternatives
	      open-bracket-prospects
	      (if most-is-exact
		  (concat "," alternatives)
		alternatives)
	      close-bracket-prospects))))))

(defun freekbs2-es-minibuffer-setup ()
  "Set up minibuffer for `freekbs2-es-buffer'.
Copied from `icomplete-minibuffer-setup-hook'."
  (when (freekbs2-es-entryfn-p)
    (set (make-local-variable 'freekbs2-es-use-mycompletion) t)
    (add-hook 'pre-command-hook 'freekbs2-es-pre-command nil t)
    (add-hook 'post-command-hook 'freekbs2-es-post-command nil t)
    (run-hooks 'freekbs2-es-minibuffer-setup-hook)))

(defun freekbs2-es-pre-command ()
  "Run before command in `freekbs2-es-buffer'."
  (freekbs2-es-tidy))

(defun freekbs2-es-post-command ()
  "Run after command in `freekbs2-es-buffer'."
  (freekbs2-es-exhibit))

(defun freekbs2-es-tidy ()
  "Remove completions display, if any, prior to new user input.
Copied from `icomplete-tidy'."

  (if (and (boundp 'freekbs2-es-eoinput)
	   freekbs2-es-eoinput)

      (if (> freekbs2-es-eoinput (point-max))
	  ;; Oops, got rug pulled out from under us - reinit:
	  (setq freekbs2-es-eoinput (point-max))
	(let ((buffer-undo-list buffer-undo-list )) ; prevent entry
	  (delete-region freekbs2-es-eoinput (point-max))))

    ;; Reestablish the local variable 'cause minibuffer-setup is weird:
    (make-local-variable 'freekbs2-es-eoinput)
    (setq freekbs2-es-eoinput 1)))

(defun freekbs2-es-entryfn-p ()
  "Return non-nil if we are using `freekbs2-es-buffer'."
  (eq freekbs2-es-minibuf-depth (minibuffer-depth)))

(defun freekbs2-es-summaries-to-end ()
  "Move the summaries to the end of the list.
This is an example function which can be hooked on to
`freekbs2-es-make-buflist-hook'.  Any buffer matching the regexps
`Summary' or `output\*$'are put to the end of the list."
  (let ((summaries (delq nil
			 (mapcar
			  (lambda (x)
			    (if (string-match "Summary\\|output\\*$" x)
				x))
			  freekbs2-es-temp-buflist))))
    (freekbs2-es-to-end summaries)))

(defun freekbs2-es-case ()
  "Return non-nil if we should ignore case when matching.
See the variable `freekbs2-es-case' for details."
  (if freekbs2-es-case
      (if (featurep 'xemacs)
	  (isearch-no-upper-case-p freekbs2-es-text)
	(isearch-no-upper-case-p freekbs2-es-text t))))

;;;###autoload
(define-minor-mode freekbs2-es-mode
  "Toggle Freekbs2-Es global minor mode.
With arg, turn Freekbs2-Es mode on if ARG is positive, otherwise turn it off.
This mode enables switching between buffers using substrings.  See
`freekbs2-es' for details."
  nil nil freekbs2-es-global-map :global t :group 'freekbs2-es
  (if freekbs2-es-mode
      (add-hook 'minibuffer-setup-hook 'freekbs2-es-minibuffer-setup)
    (remove-hook 'minibuffer-setup-hook 'freekbs2-es-minibuffer-setup)))

(provide 'freekbs2-es)

;; arch-tag: d74198ae-753f-44f2-b34f-0c515398d90a
;;; freekbs2-es.el ends here
