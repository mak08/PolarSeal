;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Description
;;; Author         Michael Kappert 2016
;;; Last Modified <michael 2017-02-25 15:40:22>

(in-package "POLARCL")

(defmacro condlet (&rest branches)
  (destructuring-bind (branch . rest)
      branches
    (cond ((listp (car branch))
           (destructuring-bind ((var form) &rest body)
               branch
             (if (null rest)
                 `(let ((,var ,form))
                    (when ,var ,@body))
                 `(let ((,var ,form))
                    (if ,var (progn ,@body)
                        (condlet ,@rest))))))
          (t
           (destructuring-bind (tag &rest body)
               branch
             (assert (eq tag t))
             (assert (null rest))
             `(progn ,@body))))))


(defmacro nnmember (item listform &key (test 'string=))
  (let ((listvar (gensym "list-")))
    `(let ((,listvar ,listform))
       (or (null ,listvar)
           (member ,item ,listvar :test ',test)))))


(defmacro with-func-from-path ((fsym request) &body body)
  `(destructuring-bind (fname functions content &rest more)
       (reverse (path ,request))
     (when more
       (error "Path too long"))
     (destructuring-bind (&optional package name)
         (cl-utilities:split-sequence #\: fname)
       (log2:info "Searching function ~a:~a" (string-upcase package) name )
       ;; Function names are case sensitive!
       (let ((,fsym (find-symbol name (string-upcase package))))
         (unless ,fsym
           (log2:warning "Unknown function ~s" ,fsym)
           (error "Function ~a:~a does not exist" package name))
         (unless (member ,fsym *registered-functions*)
           (log2:warning "Unregistered function ~s" ,fsym)
           (error "Function ~s is not registered" ,fsym))
         (log2:info "Executing ~a" ,fsym)
         ,@body))))

;;; EOF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
