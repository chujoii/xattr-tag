#!/usr/bin/guile -s
!#
; coding: utf-8

;;;; add-xattr-tag.scm ---  append new xattr to old xattr
;;;; (and add for file.ext file.etx.txt with copy of xattr)



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



;;; Keywords: set xattr tag search



;;; Usage:

;; ./add-xattr-tag.scm test.txt tag1 tag2 tag3



;;; History:

;; Version 0.1 was created at 2012.february.03



;;; Code:



(setlocale LC_ALL "en_US.UTF-8")

(load "../battery-scheme/system-cmd.scm")
(load "../battery-scheme/string.scm")
(load "../battery-scheme/unique-list.scm")
(load "xattr-config.scm")
(load "lib-xattr-tag.scm")


(define nil '())




(let ((filename (cadr (command-line)))
      (filetags (cddr (command-line))))
  (if (not (check-xattr-tag filename))
      (display "error during check\n")
      (begin (set-xattr-tag filename "user.metatag" (unique-list (append filetags (get-xattr-tag-text filename "user.metatag"))))
	     (set-info-tag filename (string-join (list filename xattr-file-extension) "")))))
