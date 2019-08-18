(asdf:defsystem #:cl-pledge
  :description "interface to OpenBSD pledge/unveil system calls"
  :author "Jeremy Mates <jmates@cpan.org>"
  :license  "BSD"
  :version "0.0.1"
  :serial t
  :depends-on (#:cffi)
  :components ((:file "cl-pledge")))
