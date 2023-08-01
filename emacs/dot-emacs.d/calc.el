
;;; Definition stored by Calc on Fri Sep 30 23:10:17 2022
(put 'calc-define 'calc-mag2db '(progn
 (defun calc-mag2db nil (interactive) (calc-wrapper (calc-enter-result 1 "mag2" (cons 'calcFunc-mag2db (calc-top-list-n 1)))))
 (put 'calc-mag2db 'calc-user-defn 't)
 (defun calcFunc-mag2db (x) (math-check-const x t) (math-normalize
  (list '* 20 (list 'calcFunc-log10 x))))
 (put 'calcFunc-mag2db 'calc-user-defn '(* 20 (calcFunc-log10 (var x
  var-x))))
 (define-key calc-mode-map "zd" 'calc-mag2db)
))

;;; Definition stored by Calc on Fri Sep 30 23:10:25 2022
(put 'calc-define 'calc-db2mag '(progn
 (defun calc-db2mag nil (interactive) (calc-wrapper (calc-enter-result 1 "db2m" (cons 'calcFunc-db2mag (calc-top-list-n 1)))))
 (put 'calc-db2mag 'calc-user-defn 't)
 (defun calcFunc-db2mag (x) (math-check-const x t) (math-normalize
  (list '^ '(float 1 1) (list '/ x 20))))
 (put 'calcFunc-db2mag 'calc-user-defn '(^ (float 1 1) (/ (var x var-x)
  20)))
 (define-key calc-mode-map "zm" 'calc-db2mag)
))
