#!/usr/bin/guile -s
!#

;;;; find-xattr-tag.scm ---  find file by xattr, and other attributes



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



;;; Keywords: find xattr tag search



;;; Usage:

;; ./find-xattr-tag.scm store/doc/ tag1 tag2 tag3
;; search in path "store/doc/" files with  "tag1 AND tag2 AND tag3"
;;
;; or you can use this command:
;;
;; find . -type f -exec getfattr -d {} \;


;;; History:

;; Version 0.1 was created at 2012.february.03



;;; Code:



(load "../battery-scheme/system-cmd.scm")
(load "../battery-scheme/string.scm")
(load "../battery-scheme/print-list.scm")
(load "lib-xattr-tag.scm")

(define nil '())



;(define (member-tf x lst)
;  (if (member x lst) #t #f))

(define (count-include x lst)
  (define (counter-true list-tf)
    (if (eq? nil list-tf)
	0
	(+ (if (car list-tf) 1 0) (counter-true (cdr list-tf)))))
  (display x)(display " === ")(display lst)(newline)
  (counter-true (map (lambda (i) (string-contains-ci i x)) lst)))


(define (include-list list-1 list-2)
  ;; list-1 included in list-2
  ;; fixme name "include-list"
  ;; fixme if initial list-1 === nil   => #t
    (if (equal? list-1 nil)
      0
      (+ (count-include (car list-1) list-2) (include-list (cdr list-1) list-2))))
;;    (and (member-tf (car list-1) list-2) (include-list (cdr list-1) list-2))))



(use-modules (ice-9 regex))
(define (get-path-file-name-tag filename)
  ;; strange but this construction not work? fixme
  ;;(map match:substring (list-matches (string-join (list "[^" (char-set->string (char-set-union char-set:punctuation char-set:whitespace)) "]")) "abc 42 def --_- -78"))
  (map match:substring (list-matches "[^- _/.]+" filename)))


  




(define (calc-rating filename tags)
  (include-list tags 
		(append (get-path-file-name-tag filename) (get-xattr-tag filename "user.metatag"))))




;(define (procf filename statinfo flag)
;  (if (and (equal? 'regular flag)
;	   (include-list  list-2) )
;	 (display filename)))
;  #t) ;; fixme


;;; help:  see doc    "guile File Tree Walk" : best= file-system-tree
;;; guile-old: ftw, nftw
;;; guile-2.0.5: file-system-tree, ftw, nftw
(use-modules (ice-9 ftw))


;;;### http://sites.google.com/site/robertharamoto/Home/programming/moving-to-guile-2
;;;### this code is free and dedicated to the public domain
;;;#############################################################
;;;#############################################################
;;;###
;;;### load list of *.scm files
;(define (list-all-scheme-files init-path file-string sub-string)
;  (let ((counter 0)
;	(file-list (list)))
;    (begin
;      (ice9-ftw:nftw
;       init-path
;       (lambda (filename statinfo flag base level)
;	 (begin
;	   (if (equal? flag 'regular)
;	       (begin
;		 (if (and
;		      (not (equal? (string-match file-string filename) #f))
;		      (not (equal? (string-match sub-string filename) #f)))
;		     (begin
;		       (set! file-list (append file-list (list (basename filename))))
;		       ))))
;	   #t)))
;      
;      file-list
;      )))

(define (list-all-files init-path)
  (let ((counter 0)
	(file-list (list)))
    (begin
      (nftw init-path
	    (lambda (filename statinfo flag base level)
	      (begin
		(if (equal? flag 'regular)
		    (set! file-list (append file-list (list filename))))
		#t)))
      
      file-list)))





(define (find-tag startpath tag-list)
  (map (lambda (filepath) (list filepath (calc-rating filepath tag-list))) (list-all-files startpath)))




(print-list-without-bracket (sort
			     (find-tag (cadr (command-line)) (cddr (command-line)))
			     (lambda (x y) (< (cadr x) (cadr y)))))





