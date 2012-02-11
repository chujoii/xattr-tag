#!/usr/bin/guile -s
!#

;;;; lib-xattr-tag.scm ---  library functions work with xattr



;;; Copyright (C) 2012 Roman V. Prikhodchenko



;;; Author: Roman V. Prikhodchenko <chujoii@gmail.com>



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



;;; Keywords: library xattr tag



;;; Usage:

;; use it



;;; History:

;; Version 0.1 was created at 2012.february.03



;;; Code:



;;; ------------------------------------ set

(define (set-xattr-tag file-name tag-name tags-list)
  (system (string-join (list "setfattr"
			     " -n " tag-name
			     " -v \"" (string-join tags-list " ") "\""
			     "    " file-name)
		       "")))


;;(define (set-info-file file tag-list)
;;  (define info-file (open-output-file file))
;;  (write tag-list info-file)
;;  (write (newline) info-file)
;;  (close info-file))

(define (set-info-file file)
  (system (string-join (list "getfattr --dump " filename " > " filename ".txt") "")))



;;; ------------------------------------ get
(use-modules (ice-9 regex))
(define (get-xattr-tag filename tag-name)
  (let ((getfattr-result (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -n " tag-name " " filename)))))))
    (if (eq? nil getfattr-result)
	nil
	(string-split
	 (string-cut
	  (car getfattr-result) 1 -1)
	 ;;(car (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -n user.metatag " filename))))))
	 ;; fixme (?<=").*(?=")
	 #\ ))))



;;; ------------------------------------- check

(define (check-xattr-tag filename)
  (let ((chk-md5 (equal? (get-xattr-tag filename "user.checksum.md5")
			 (list (car (string-split (system-with-output-to-string (string-join (list "md5sum -b " filename))) #\ )))))
	(chk-sha1 (equal? (get-xattr-tag filename "user.checksum.sha1")
			  (list (car (string-split (system-with-output-to-string (string-join (list "sha1sum -b " filename))) #\ )))))
	(chk-sha256 (equal? (get-xattr-tag filename "user.checksum.sha256")
			    (list (car (string-split (system-with-output-to-string (string-join (list "sha256sum -b " filename))) #\ ))))))
    
    (and chk-md5 chk-sha1 chk-sha256)))

