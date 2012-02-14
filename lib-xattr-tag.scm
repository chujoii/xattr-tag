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

(define (set-xattr-tag filename tag-name tags-list)
  (system (string-join (list "setfattr"
			     " -n " tag-name
			     " -v \"" (string-join tags-list " ") "\""
			     "    \"" filename "\"")
		       "")))


;;(define (set-info-file file tag-list)
;;  (define info-file (open-output-file file))
;;  (write tag-list info-file)
;;  (write (newline) info-file)
;;  (close info-file))

(define (set-info-tag filename result-file)
  (system (string-join (list "getfattr --dump \"" filename "\" > \"" result-file "\"") "")))



;;; ------------------------------------ get
(use-modules (ice-9 regex))
(define (get-xattr-tag filename tag-name)
  (let ((getfattr-result (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -n " tag-name " \"" filename "\"") "")))))) ;; filename with quotes because it can contain space
    (if (eq? nil getfattr-result)
	nil
	(string-split
	 (string-cut
	  (car getfattr-result) 1 -1)
	 ;;(car (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -n user.metatag " filename))))))
	 ;; fixme (?<=").*(?=")
	 #\ ))))



(define (get-xattr-raw-tag filename)
  (system-with-output-to-string (string-join (list "getfattr --dump \"" filename "\"") "")))



;(define (get-info-raw-tag filename)
;  (define info-file (open-input-file filename))
;  (let ((data (read info-file)))
;    (close info-file)
;    data))
;
(use-modules (ice-9 rw))
(define (file-contents file)
  ;; from http://pleac.sourceforge.net/pleac_guile/filecontents.html
  ;; fixme need check exist of file
  (call-with-input-file file
    (lambda (p)
      (let* ((size (stat:size (stat p)))
             (buf (make-string size)))
        (read-string!/partial buf p)
        buf))))




;;; ------------------------------------- check

(define (get-md5 filename)
  (car (string-split (system-with-output-to-string (string-join (list "md5sum -b \"" filename "\"") "")) #\ )))

(define (get-sha1 filename)
  (car (string-split (system-with-output-to-string (string-join (list "sha1sum -b \"" filename "\"") "")) #\ )))

(define (get-sha256 filename)
(car (string-split (system-with-output-to-string (string-join (list "sha256sum -b \"" filename "\"") "")) #\ )))

(define (check-xattr-tag filename)
  (let ((chk-md5    (equal? (get-xattr-tag filename "user.checksum.md5")
			    (list (get-md5 filename))))
	(chk-sha1   (equal? (get-xattr-tag filename "user.checksum.sha1")
			    (list (get-sha1 filename))))
	(chk-sha256 (equal? (get-xattr-tag filename "user.checksum.sha256")
			    (list (get-sha256 filename))))
	(chk-info   (let ((stored-xattr-tag (file-contents (string-join (list "\"" filename ".txt\"") "")))
			  (generated-xattr-tag (get-xattr-raw-tag filename)))
		      ;; remove first line because it contains file name with absolute path OR file name with relative path
		      (string= (string-take-right stored-xattr-tag (- (string-length stored-xattr-tag) (string-index stored-xattr-tag #\
) 1))
			       (string-take-right generated-xattr-tag (- (string-length generated-xattr-tag) (string-index generated-xattr-tag #\
) 1))))))

    (display "check md5\t")(display chk-md5)(newline)
    (display "check sha1\t")(display chk-sha1)(newline)
    (display "check sha256\t")(display chk-sha256)(newline)
    (display "check info\t")(display chk-info)(newline)

    (and chk-md5 chk-sha1 chk-sha256 chk-info)))

