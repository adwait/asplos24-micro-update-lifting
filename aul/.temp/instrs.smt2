(set-option :random-seed 302)
(declare-fun x0 () (_ BitVec 32))
(declare-fun x1 () (_ BitVec 32))
(declare-fun x2 () (_ BitVec 32))
(declare-fun x3 () (_ BitVec 32))
(declare-fun x4 () (_ BitVec 32))
(declare-fun x5 () (_ BitVec 32))
(declare-fun x6 () (_ BitVec 32))
(declare-fun x7 () (_ BitVec 32))


(assert (and
    (= ((_ extract 6 0) x0) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x0) #b101) (= ((_ extract 14 12) x0) #b000))) (= ((_ extract 31 25) x0) #b0000000))
    (or (= ((_ extract 31 25) x0) #b0000000) (= ((_ extract 31 25) x0) #b0100000))
    ;; (=> (= ((_ extract 14 12) x0) #b101) (and (= ((_ extract 31 31) x0) #b0) (= ((_ extract 29 25) x0) #b00000)))
))



(assert (and
    (= ((_ extract 6 0) x1) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x1) #b101) (= ((_ extract 14 12) x1) #b000))) (= ((_ extract 31 25) x1) #b0000000))
    (or (= ((_ extract 31 25) x1) #b0000000) (= ((_ extract 31 25) x1) #b0100000))
    ;; (=> (= ((_ extract 14 12) x1) #b101) (and (= ((_ extract 31 31) x1) #b0) (= ((_ extract 29 25) x1) #b00000)))
))



(assert (and
    (= ((_ extract 6 0) x2) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x2) #b101) (= ((_ extract 14 12) x2) #b000))) (= ((_ extract 31 25) x2) #b0000000))
    (or (= ((_ extract 31 25) x2) #b0000000) (= ((_ extract 31 25) x2) #b0100000))
    ;; (=> (= ((_ extract 14 12) x2) #b101) (and (= ((_ extract 31 31) x2) #b0) (= ((_ extract 29 25) x2) #b00000)))
))



(assert (and
    (= ((_ extract 6 0) x3) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x3) #b101) (= ((_ extract 14 12) x3) #b000))) (= ((_ extract 31 25) x3) #b0000000))
    (or (= ((_ extract 31 25) x3) #b0000000) (= ((_ extract 31 25) x3) #b0100000))
    ;; (=> (= ((_ extract 14 12) x3) #b101) (and (= ((_ extract 31 31) x3) #b0) (= ((_ extract 29 25) x3) #b00000)))
))



(assert (and
    (= ((_ extract 6 0) x4) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x4) #b101) (= ((_ extract 14 12) x4) #b000))) (= ((_ extract 31 25) x4) #b0000000))
    (or (= ((_ extract 31 25) x4) #b0000000) (= ((_ extract 31 25) x4) #b0100000))
    ;; (=> (= ((_ extract 14 12) x4) #b101) (and (= ((_ extract 31 31) x4) #b0) (= ((_ extract 29 25) x4) #b00000)))
))



(assert (and
    (= ((_ extract 6 0) x5) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x5) #b101) (= ((_ extract 14 12) x5) #b000))) (= ((_ extract 31 25) x5) #b0000000))
    (or (= ((_ extract 31 25) x5) #b0000000) (= ((_ extract 31 25) x5) #b0100000))
    ;; (=> (= ((_ extract 14 12) x5) #b101) (and (= ((_ extract 31 31) x5) #b0) (= ((_ extract 29 25) x5) #b00000)))
))



(assert (and
    (= ((_ extract 6 0) x6) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x6) #b101) (= ((_ extract 14 12) x6) #b000))) (= ((_ extract 31 25) x6) #b0000000))
    (or (= ((_ extract 31 25) x6) #b0000000) (= ((_ extract 31 25) x6) #b0100000))
    ;; (=> (= ((_ extract 14 12) x6) #b101) (and (= ((_ extract 31 31) x6) #b0) (= ((_ extract 29 25) x6) #b00000)))
))



(assert (and
    (= ((_ extract 6 0) x7) #b0110011)
    (=> (not (or (= ((_ extract 14 12) x7) #b101) (= ((_ extract 14 12) x7) #b000))) (= ((_ extract 31 25) x7) #b0000000))
    (or (= ((_ extract 31 25) x7) #b0000000) (= ((_ extract 31 25) x7) #b0100000))
    ;; (=> (= ((_ extract 14 12) x7) #b101) (and (= ((_ extract 31 31) x7) #b0) (= ((_ extract 29 25) x7) #b00000)))
))


(assert (and (or  (and (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000)))) (and (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000)))) (and (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000)))) (and (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000)))))
(or  (and (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000)))) (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000)))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000)))) (and (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000)))) (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000)))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000)))) (and (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000)))) (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000)))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000)))) (and (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000)))) (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000)))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000)))))
(or  (and (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000)))) (and (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000)))) (and (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000)))) (and (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000)))))
(or  (and (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000)))) (and (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000)))) (and (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000)))) (and (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000)))))
(or  (and (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000)))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000))) (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000))))) (and (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000)))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000))) (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000))))) (and (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000)))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000))) (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000))))) (and (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000)))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000))) (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000))))))
(or  (and (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000))) (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000)))) (and (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000))) (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000)))) (and (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000))) (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000)))) (and (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000))) (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000)))))
(or  (and (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000)))) (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000)))) (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000))))) (and (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000)))) (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000)))) (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000))))) (and (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000)))) (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000)))) (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000))))) (and (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000)))) (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000)))) (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000))))))
(or  (and (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x2)) (not (= ((_ extract 19 15) x1) #b00000)))) (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x1) #b00000)))) (not (and (= ((_ extract 19 15) x1) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x1) #b00000))))) (and (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x3)) (not (= ((_ extract 19 15) x2) #b00000)))) (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x2) #b00000)))) (not (and (= ((_ extract 19 15) x2) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x2) #b00000))))) (and (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x4)) (not (= ((_ extract 19 15) x3) #b00000)))) (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x3) #b00000)))) (not (and (= ((_ extract 19 15) x3) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x3) #b00000))))) (and (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x5)) (not (= ((_ extract 19 15) x4) #b00000)))) (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x6)) (not (= ((_ extract 19 15) x4) #b00000)))) (not (and (= ((_ extract 19 15) x4) ((_ extract 11 7) x7)) (not (= ((_ extract 19 15) x4) #b00000))))))))

(check-sat)
(get-value (x0 x1 x2 x3 x4 x5 x6 x7))