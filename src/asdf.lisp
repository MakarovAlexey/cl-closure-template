(in-package #:closure-template)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass closure-template-file (asdf:cl-source-file)
    ((type :initform "soy"))))

(defun process-template (input-file output-fasl-file)
  (let ((output-lisp-file (merge-pathnames
			   (make-pathname :type "lisp")
			   output-fasl-file)))
    (with-open-file (source-stream output-lisp-file
				   :direction :output
				   :if-exists :supersede)
      (with-standard-io-syntax 
	(print `(closure-template:compile-template :common-lisp-backend
						   ,input-file)
	       source-stream)))
    output-lisp-file))

(defmethod asdf:perform ((op asdf:compile-op) (c closure-template-file))
  (let ((output-fasl-file (first (asdf:output-files op c))))
    (compile-file (process-template
		   (asdf:component-pathname c) output-fasl-file)
		  :output-file output-fasl-file)))

(defmethod asdf:perform ((op asdf:load-source-op) (c closure-template-file))
  (compile-template :common-lisp-backend
		    (asdf:component-pathname c)))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (setf (find-class 'asdf::closure-template-file) (find-class 'closure-template-file)))