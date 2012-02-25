#!/usr/bin/guile -s
!#
; coding: utf-8

;;;; generate-xattr-tag.scm ---  generate list xattr tag for zsh completion system



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



;;; Keywords: generate list xattr tag zsh completion auto-completion



;;; Usage:

;; ./generate-xattr-tag.scm store/doc/


;;; History:

;; Version 0.1 was created at 2012.february.25



;;; Code:



(setlocale LC_ALL "en_US.UTF-8")

(define nil '())

(load "../battery-scheme/system-cmd.scm")
(load "../battery-scheme/string.scm")
(load "../battery-scheme/print-list.scm")
(load "../battery-scheme/recursive-file-list.scm")
(load "../battery-scheme/unique-list.scm")
(load "xattr-config.scm")
(load "lib-xattr-tag.scm")



(define (load-exist-tag filename)
  ;; may require verification of data
  (read (open-file filename "r")))



(define (2d-1d start-list)
  (define (flat flat-list dim-list)
    (if (null? dim-list)
	flat-list
	(flat (append flat-list (car dim-list)) (cdr dim-list))))
  (flat (list) start-list))

(define (generate-tag-list path)
  (unique-list (2d-1d (map (lambda (file-tag) (cdr file-tag)) (generate-list-file-tag path)))))


(define (generate-zsh-completion-file zsh-file string-tags)
  (define p-file (open-output-file zsh-file))
  (display (string-join (list "#compdef add-xattr-tag.scm find-xattr-tag.scm set-xattr-tag.scm\n\n_xattr () {\n_arguments \"1:path:_files\" \"*:tags:("
			    string-tags
			    ")\"\n}\n\n_xattr \"$@\" && return 0\n")
		      "")
	 p-file)
  (close p-file))


(define (generate-list-xattr-tag-file tag-file list-tags)
  (define p-file (open-output-file tag-file))
  (write list-tags
	 p-file)
  (close p-file))


(let ((path (cadr (command-line))))
  (let ((tag-list (unique-list (append (generate-tag-list path) (load-exist-tag *list-xattr-tag-file*)))))
    
    (generate-zsh-completion-file *zsh-completion-file* (string-join tag-list " "))
    (generate-list-xattr-tag-file *list-xattr-tag-file* tag-list)))


