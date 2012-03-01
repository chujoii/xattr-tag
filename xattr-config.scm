;; extension of the file which stores duplicate information
(define *xattr-file-extension* ".txt")



;; full path to the zsh auto-completion file
(define *zsh-completion-file* (string-join (list *XDG_CONFIG_HOME* "/zsh/completion/_xattr-tag") ""))





;; full path to the file that stores a list of used tags
(define *list-xattr-tag-file* (string-join (list *XDG_CACHE_HOME* "/xattr-tag/list-xattr-tag.scm") ""))

