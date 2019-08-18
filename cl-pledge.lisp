;;;;; cl-pledge - interface to the OpenBSD pledge/unveil system calls

(in-package #:cl-user)
(defpackage #:cl-pledge
  (:use #:common-lisp #:cffi)
  (:export #:pledge #:unveil #:unveil-lockdown))
(in-package #:cl-pledge)

; nope - SBCL on OpenBSD 6.5 barfs {Trying to access undefined foreign
; variable "errno"} when attempt to access *errno*. so instead we fail
; the entire process with err(3) which should print the strerror(3)
;(defcvar "errno" :int)

(defcfun ("err" %err) :void (n :int) (p :pointer))
(defcfun ("pledge" %pledge) :int (promise :pointer) (epromise :pointer))
(defcfun ("unveil" %unveil) :int (path :pointer) (perms :pointer))

(defun pledge
  (&key (promises (null-pointer) promises-p)
        (execpromises (null-pointer) execpromises-p))
  "force the process into a restricted service operating mode"
  (unwind-protect
      (progn
       (when promises-p
         (unless (stringp promises) (error "promises must be a string"))
         (setf promises (foreign-string-alloc promises :encoding :ascii)))
       (when execpromises-p
         (unless (stringp execpromises)
           (error "execpromises must be a string"))
         (setf execpromises
                 (foreign-string-alloc execpromises :encoding :ascii)))
       (when (= (%pledge promises execpromises) -1)
         (%err 1 (foreign-string-alloc "pledge failed"))))
    (progn
     (when promises-p (foreign-string-free promises))
     (when execpromises-p (foreign-string-free execpromises))))
  (values))

(defun unveil (path permissions)
  "unveil parts of a restricted filesystem view"
  (unless (stringp path) (error "path must be a string"))
  (unless (stringp permissions) (error "permissions must be a string"))
  (with-foreign-strings ((cpath path) (cperm permissions))
   (when (= (%unveil cpath cperm) -1)
     (%err 1 (foreign-string-alloc "unveil failed"))))
  (values))

; this is to spare the previous from some sort of string-or-nil? checks
(defun unveil-lockdown ()
  "prevent future calls to unveil"
  (when (= (%unveil (null-pointer) (null-pointer)) -1)
    (%err 1 (foreign-string-alloc "unveil-lockdown failed")))
  (values))
