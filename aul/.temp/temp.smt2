(declare-fun x0 () (_ BitVec 63))
(declare-fun x1 () (_ BitVec 1))

(assert (and (= x1 #b1)
(= ((_ extract 62 62) x0) #b1)))

(check-sat)
(get-value (x0 x1))