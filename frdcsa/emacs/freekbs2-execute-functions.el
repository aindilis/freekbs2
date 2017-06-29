(defun freekbs2-execute-functions-radar-web-search (search)
 "take the item on stack and run radar web search on the it"
 (shell-command-to-string (concat "radar-web-search \"" (shell-quote-argument search) "\"")))

(defun freekbs2-execute-functions-lookup (search)
 "take the item on stack and run radar web search on the it"
 (shell-command-to-string (concat "radar-web-search \"" (shell-quote-argument search) "\"")))

(defun freekbs2-execute-functions-w3m-search (search)
 "take the item on stack and run radar web search on the it"
 (if (string= mode-name "w3m")
  (w3m-copy-buffer))
 (w3m-search "google" search))

(defun freekbs2-execute-functions-lookup-pattern (search)
 "take the item on stack and run radar web search on the it"
 (lookup-pattern search))

(defun freekbs2-execute-functions-lookup-item-extensively (search)
 "take the item on stack and run radar web search on the it"
 (freekbs2-execute-functions-w3m-search search)
 (freekbs2-execute-functions-lookup-pattern search))

(defun freekbs2-execute-functions-kmax-search-buffers (search)
 "search kmax"
 (kmax-search-buffers search))
