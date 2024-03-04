(set-logic UF)
(synth-fun gen_flush_all ((x0 Bool) (x1 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1) ) )
)
        


(synth-fun gen_update ((x0 Bool) (x1 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1) ) )
)
        


(synth-fun gen_none ((x0 Bool) (x1 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1) ) )
)
        
(declare-var x0 Bool)
(declare-var x1 Bool)
(constraint (not (and (gen_flush_all x0 x1) (gen_update x0 x1))))
(constraint (not (and (gen_flush_all x0 x1) (gen_none x0 x1))))
(constraint (not (and (gen_update x0 x1) (gen_flush_all x0 x1))))
(constraint (not (and (gen_update x0 x1) (gen_none x0 x1))))
(constraint (not (and (gen_none x0 x1) (gen_flush_all x0 x1))))
(constraint (not (and (gen_none x0 x1) (gen_update x0 x1))))
(constraint (or (gen_flush_all x0 x1) (gen_update x0 x1) (gen_none x0 x1)))
(constraint (not (gen_flush_all false true)))
(constraint (not (gen_none false true)))
(constraint (not (gen_update true false)))
(constraint (not (gen_none true false)))
(constraint (not (gen_flush_all false true)))
(constraint (not (gen_none false true)))
(constraint (not (gen_update true false)))
(constraint (not (gen_none true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_none true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_flush_all false true)))
(constraint (not (gen_none false true)))
(constraint (not (gen_update true false)))
(constraint (not (gen_none true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_none true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_flush_all false true)))
(constraint (not (gen_none false true)))
(constraint (not (gen_flush_all false true)))
(constraint (not (gen_none false true)))
(constraint (not (gen_update true false)))
(constraint (not (gen_none true false)))
(constraint (not (gen_flush_all false true)))
(constraint (not (gen_none false true)))
(constraint (not (gen_update true false)))
(constraint (not (gen_none true false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_flush_all false true)))
(constraint (not (gen_none false true)))
(constraint (not (gen_update false false)))
(constraint (not (gen_update true false)))
(constraint (not (gen_flush_all false false)))
(constraint (not (gen_update false false)))

(check-synth)