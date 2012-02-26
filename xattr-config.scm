;; extension of the file which stores duplicate information
(define *xattr-file-extension* ".txt")

;; full path to the zsh auto-completion file
(define *zsh-completion-file* (string-join (list *user-home-dir* "/.config/zsh/completion/_xattr-tag") ""))

;; full path to the file that stores a list of used tags
(define *list-xattr-tag-file* (string-join (list *user-home-dir* "/.cache/xattr-tag/list-xattr-tag.scm") ""))
