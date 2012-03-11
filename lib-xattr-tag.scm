; coding: utf-8

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



(setlocale LC_ALL "en_US.UTF-8")



;(define *user-home-dir* (array-ref (getpwuid (geteuid)) 5)) ;; fixme : which solution is more correct?
(define *user-home-dir* (getenv "HOME"))



(define *XDG_CONFIG_HOME*
  (let ((xdg-cfg (getenv "XDG_CONFIG_HOME")))
    (if xdg-cfg
	xdg-cfg
	(string-join (list *user-home-dir* "/.config") ""))))



(define *XDG_CACHE_HOME*
  (let ((xdg-cache (getenv "XDG_CACHE_HOME")))
    (if xdg-cache
	xdg-cache
	(string-join (list *user-home-dir* "/.cache") ""))))



(define nil '())

(load "../battery-scheme/file-contents.scm")
(load "../battery-scheme/system-cmd.scm")
(load "../battery-scheme/string.scm")
(load "../battery-scheme/print-list.scm")
(load "../battery-scheme/recursive-file-list.scm")
(load "../battery-scheme/unique-list.scm")
(load "../battery-scheme/dir-and-file.scm")
(load "../battery-scheme/flat-list.scm")


(let ((user-xattr-cfg (string-join (list *XDG_CONFIG_HOME*  "/xattr-tag/xattr-config.scm") "")))
  (copy-if-not-exist-file "xattr-config.scm" user-xattr-cfg)
  (load user-xattr-cfg))


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

(define (get-xattr-tag-text filename tag-name)
  (let ((getfattr-result (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -e text -n " tag-name " \"" filename "\" 2>/dev/null ") "")))))) ;; filename with quotes because it can contain space
    (if (null? getfattr-result)
	nil
	(string-split
	 (string-cut
	  (car getfattr-result) 1 -1)
	 ;;(car (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -n user.metatag " filename))))))
	 ;; fixme (?<=").*(?=")
	 #\space))))



(define (get-xattr-tag-default filename tag-name)
  ;; default for ASCII = text; for nonlatin symbols = base64
  (let ((getfattr-result (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -n " tag-name " \"" filename "\" 2>/dev/null ") "")))))) ;; filename with quotes because it can contain space
    (if (null? getfattr-result)
	nil
	(string-split
	 (string-cut
	  (car getfattr-result) 1 -1)
	 ;;(car (map match:substring (list-matches "\"(.*?)\"" (system-with-output-to-string (string-join (list "getfattr -n user.metatag " filename))))))
	 ;; fixme (?<=").*(?=")
	 #\space))))



(define (get-xattr-raw-tag filename)
  (system-with-output-to-string (string-join (list "getfattr --dump \"" filename "\" 2>/dev/null ") "")))



(define (generate-list-file-tag-nftw startpath)
  (map (lambda (filepath) (append (list filepath) (get-xattr-tag-text filepath "user.metatag"))) (list-all-files startpath)))




(use-modules (ice-9 ftw))
(define (generate-list-file-tagfile-system-fold start-dir)
  "Return the list of file name and xattr-tag"

  (define (enter? name stat result)
    ;; fixme need ad *xattr-file-extension*
    ;;(not (member (basename name) '(*xattr-file-extension* ".git" ".svn" "CVS"))))
    #t)

  (define (leaf name stat result)
    ;; Return RESULT plus the size of the file at NAME.
    ;;(display "leaf=")(display name)(newline)
    (cons (cons name (get-xattr-tag-text name "user.metatag")) result))
    
  ;; Count zero bytes for directories. fixme: duplicate function
  (define (down name stat result) 
    (cons (cons name (get-xattr-tag-text name "user.metatag")) result))

  (define (up name stat result) 
    (cons (cons name (get-xattr-tag-text name "user.metatag")) result))

  ;; Likewise for skipped directories.
  (define (skip name stat result) result)

  ;; Ignore unreadable files/directories but warn the user.
  (define (error name stat errno result)
    (format (current-error-port) "warning: ~a: ~a~%"
	    name (strerror errno))
    result)

  (file-system-fold enter? leaf down up skip error
		    '() ; initial counter is zero bytes
		    start-dir))



(define (load-exist-tag filename)
  (create-if-not-exist-file-with-write filename nil)
  ;; fixme: may require verification of data
  (read (open-file filename "r")))




(define (generate-recursive-list-file-tag start-dir)
  ;; this function is identical to generate-list-file-tag in input and output parameters.
  ;; but there is one difference:
  ;; in the function generate-list-file-tag getfattr call for each file,
  ;; and this function is called once "getfattr -R" for recursively crawling.

  ;; so this function generate-recursive-globbing-list-file-tag is much faster
  ;; for example:
  ;; generate-list-file-tag-nftw                 8.9s
  ;; generate-list-file-tagfile-system-fold     13.0s
  ;; generate-recursive-globbing-list-file-tag   0.6s

  ;; getfattr "generate -n user.metatag ... 2>&1"  output:
  
  ;; 0 q: user.metatag: No such attribute
  ;; 1 # file: q/test.txt
  ;; 2 user.metatag="foo bar"
  ;; 3 
  ;; 4 q/test.txt.txt: user.metatag: No such attribute

  ;; 0 without metatag
  ;; 1,2,3 with metatag (3 - empty string)
  ;; 4 without metatag


  (define (reconstruct-file-without-metatag file-string file-string-index)
    (string-take file-string file-string-index))
  (define (reconstruct-file-with-metatag file-string)
    ;; (string-length "# file: ") === 8
    (string-drop file-string 8))
  (define (reconstruct-tag tag-string)
    ;; (string-length "user.metatag=\"") === 14
    ;; (string-length "\"") === 1
    (display tag-string)(newline)
    (string-split (string-cut tag-string 14 -1) #\space))

  (define (reconstruct-list-file-tag getfattr-list)
    ;;(display "getfattr-list = ")(write getfattr-list)(newline)
    ;;(display "ififififififif = ")(display (null? getfattr-list))(newline)
    (if (or (null? getfattr-list) (equal? getfattr-list (list "")))
	nil
	(let ((file-string (car getfattr-list))
	      (file-string-index (string-contains file-string ": user.metatag: No such attribute")))
	  ;;(display file-string-index)(display " ")(display file-string)(newline)
	  (if file-string-index
	      ;; without metatag
	      (cons (cons (reconstruct-file-without-metatag file-string file-string-index)
			  '())
		    (reconstruct-list-file-tag (cdr getfattr-list)))
	      ;; with metatag
	      (cons (cons (reconstruct-file-with-metatag file-string)
			  (reconstruct-tag (cadr getfattr-list)))
		    (reconstruct-list-file-tag (cdddr getfattr-list)))))))
    
  (reconstruct-list-file-tag 
   (string-split
    (system-with-output-to-string (string-append "getfattr --absolute-names -R -e \"text\" -n user.metatag \"" start-dir "\" 2>&1 "))
    #\newline)))

;;; ------------------------------------- check

(define (get-md5 filename)
  (car (string-split (system-with-output-to-string (string-join (list "md5sum -b \"" filename "\"") "")) #\space)))

(define (get-sha1 filename)
  (car (string-split (system-with-output-to-string (string-join (list "sha1sum -b \"" filename "\"") "")) #\space)))

(define (get-sha256 filename)
  (car (string-split (system-with-output-to-string (string-join (list "sha256sum -b \"" filename "\"") "")) #\space)))

(define (check-xattr-tag filename)
  (let ((chk-md5    (equal? (get-xattr-tag-default filename "user.checksum.md5")
			    (list (get-md5 filename))))
	(chk-sha1   (equal? (get-xattr-tag-default filename "user.checksum.sha1")
			    (list (get-sha1 filename))))
	(chk-sha256 (equal? (get-xattr-tag-default filename "user.checksum.sha256")
			    (list (get-sha256 filename))))
	(chk-info   (let ((stored-xattr-tag (file-contents (string-join (list filename *xattr-file-extension*) "")))
			  (generated-xattr-tag (string-cut (get-xattr-raw-tag filename) 0 -1)))
		      ;; remove first line because it contains file name with absolute path OR file name with relative path
		      (string= (string-take-right stored-xattr-tag    (- (string-length stored-xattr-tag) (string-index stored-xattr-tag #\newline) 1))
			       (string-take-right generated-xattr-tag (- (string-length generated-xattr-tag) (string-index generated-xattr-tag #\newline) 1))))))


    (display "check md5\t")(display chk-md5)(newline)
    (display "check sha1\t")(display chk-sha1)(newline)
    (display "check sha256\t")(display chk-sha256)(newline)
    (display "check info\t")(display chk-info)(newline)

    (and chk-md5 chk-sha1 chk-sha256 chk-info)))


;;; ------------------------------------- zsh auto-completion

(define (generate-zsh-completion-file zsh-file string-tags)
  (display-to-file zsh-file 
		   (string-join (list "#compdef add-xattr-tag.scm find-xattr-tag.scm set-xattr-tag.scm\n\n_xattr () {\n_arguments \"1:path:_files\" \"*:tags:("
				      string-tags
				      ")\"\n}\n\n_xattr \"$@\" && return 0\n")
				""))

  ;; automaticaly update zsh auto-completion function
  ;; fixme: not work because run in "sh" not in "zsh"?
  ;; fixme: need do update only if _xattr-tag changed?
  ;;(system "unfunction  _xattr-tag")
  ;;(system "autoload -U _xattr-tag"))
  )

(define (append-to-index-and-save tag-list)
  (let ((full-tag-list (unique-list (append tag-list (load-exist-tag *list-xattr-tag-file*)))))
    
    (generate-zsh-completion-file *zsh-completion-file* (string-join full-tag-list " "))
    (write-to-file *list-xattr-tag-file* full-tag-list)))
