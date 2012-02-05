;; read result of system call
;;
;; http://sources.redhat.com/ml/guile/2000-09/msg00102.html 
;; this code is free and dedicated to the public domain
;;
;; author
;; Dale P. Smith
;; Altus Technologies Corp.
;; dsmith@altustech.com
;; 400-746-9000 x309
;;


(use-modules (ice-9 popen))
(use-modules (ice-9 rdelim))

(define (system-with-output-to-string command)
  (let* ((p (open-input-pipe command))
	 (output (read-delimited "" p)))
    (if (eof-object? output)
	""
	output)))
