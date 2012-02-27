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

;; generate-xattr-tag.scm   path/to/file/storage


;;; History:

;; Version 0.1 was created at 2012.february.03



;;; Code:



(load "lib-xattr-tag.scm")








(define (generate-tag-list path)
  (unique-list (2d-1d (map (lambda (file-tag) (cdr file-tag)) (generate-list-file-tag path)))))



(let ((path (cadr (command-line))))
  (append-to-index-and-save (generate-tag-list path)))
