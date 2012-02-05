#!/usr/bin/guile -s
!#

;;; use:
;;; ./find-xattr-tag.scm test.txt tag1 tag2 tag3

(display "file: ")(display (cadr (command-line)))(newline)
(display "tag: ")(display (cddr (command-line)))(newline)

(define (set-tag file tag-list)
  (string-join (list "setfattr -n user.metatag -v"
		     " \""
		     (string-join tag-list " ")
		     "\" "
		     file)
	       ""))


(system (set-tag (cadr (command-line)) (cddr (command-line))))



