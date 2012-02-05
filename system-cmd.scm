;; http://sources.redhat.com/ml/guile/2000-09/msg00102.html 
;; read result of system call

(use-modules (ice-9 popen))
(use-modules (ice-9 rdelim))

(define (system-with-output-to-string command)
  (let* ((p (open-input-pipe command))
	 (output (read-delimited "" p)))
    (if (eof-object? output)
	""
	output)))
