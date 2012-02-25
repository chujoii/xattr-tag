#!/usr/bin/guile -s
!#
; coding: utf-8

;;;; set-xattr-tag.scm ---  write (delete old xattr) to file
;;;; (and duplicate xattr in file file.ext.txt (for file.ext))



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

;; ./find-xattr-tag.scm test.txt tag1 tag2 tag3



;;; History:

;; Version 0.1 was created at 2012.february.03



;;; Code:



(setlocale LC_ALL "en_US.UTF-8")

(load "../battery-scheme/system-cmd.scm")
(load "xattr-config.scm")
(load "lib-xattr-tag.scm")



;; bug in ?all? version before 2.0.? (2.0.1 with bug) with function 'command-line"
;; http://lists.gnu.org/archive/html/guile-user/2011-11/msg00015.html
;; i am use git version (guile (GNU Guile) 2.1.0.48-3c65e)

(let ((filename (cadr (command-line)))
      (filetags (cddr (command-line))))

  
  (display "filename=")(display filename)(newline)
  (display "filetags=")(display filetags)(newline)

  (set-xattr-tag filename "user.metatag" filetags)

  (set-xattr-tag filename "user.checksum.md5"
		 (list (get-md5 filename)))

  (set-xattr-tag filename "user.checksum.sha1"
		 (list (get-sha1 filename)))

  (set-xattr-tag filename "user.checksum.sha256"
		 (list (get-sha256 filename)))
  
  (set-info-tag filename (string-join (list filename *xattr-file-extension*) "")))


