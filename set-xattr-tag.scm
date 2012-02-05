#!/usr/bin/guile -s
!#

;;;; set-xattr-tag.scm ---  write (delete old xattr) to file
;;;; (and add for file.ext file.etx.txt with copy of xattr)



;;; Copyright (C) 2012 Roman V. Prikhodchenko



;;; Author: Roman V. Prikhodchenko <chujoii@gmail.com>
;;; Keywords: set xattr tag search



;;;    This file is part of xattr-tag.
;;;
;;;    xattr-tag is free software: you can redistribute it and/or modify
;;;    it under the terms of the GNU General Public License as published by
;;;    the Free Software Foundation, either version 3 of the License, or
;;;    (at your option) any later version.
;;;
;;;    xattr-tag is distributed in the hope that it will be useful,
;;;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;    GNU General Public License for more details.
;;;
;;;    You should have received a copy of the GNU General Public License
;;;    along with xattr-tag.  If not, see <http://www.gnu.org/licenses/>.



;;; Usage:

;; ./find-xattr-tag.scm test.txt tag1 tag2 tag3



;;; History:

;; Version 0.1 was created at 2012.february.03



;;; Code:



(load "system-cmd.scm")



(display "file: ")(display (cadr (command-line)))(newline)
(display "tag: ")(display (cddr (command-line)))(newline)

(define (set-user.metatag file tag-list)
  (string-join (list "setfattr -n user.metatag -v"
		     " \""
		     (string-join tag-list " ")
		     "\" "
		     file)
	       ""))




(define (set-xattr-tag file-name tag-name tags-list)
  (system (string-join (list "setfattr"
			     " -n " tag-name
			     " -v \"" (string-join tags-list " ") "\""
			     "    " file-name)
		       "")))



(define (set-checksum file tag-list)
  (string-join (list "setfattr -n user.checksum.md5 -v"
		     " \""
		     (string-join tag-list " ")
		     "\" "
		     file)
	       ""))




;;(define (set-info-file file tag-list)
;;  (define info-file (open-output-file file))
;;  (write tag-list info-file)
;;  (write (newline) info-file)
;;  (close info-file))

(let ((filename (cadr (command-line)))
      (filetags (cddr (command-line))))

  (set-xattr-tag filename "user.metatag" filetags)

  (set-xattr-tag filename "user.checksum.md5"
		 (list (car (string-split (system-with-output-to-string (string-join (list "md5sum -b " filename))) #\ ))))

  (set-xattr-tag filename "user.checksum.sha1"
		 (list (car (string-split (system-with-output-to-string (string-join (list "sha1sum -b " filename))) #\ ))))

  (set-xattr-tag filename "user.checksum.sha256"
		 (list (car (string-split (system-with-output-to-string (string-join (list "sha256sum -b " filename))) #\ )))))

  
;  (system (string-join (list "getfattr --dump " filename " >") "")))


