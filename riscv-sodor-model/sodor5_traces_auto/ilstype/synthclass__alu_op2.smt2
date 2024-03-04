(set-logic UF)
(synth-fun feed__imm_i__alu_op2 ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B4 Bool) (B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B4 Bool (true false (and B3 B3) (or B3 B3) (not B3) x0 x1 x2 x3))
(B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3))
(B0 Bool (true false x0 x1 x2 x3)))
        
)
        


(synth-fun feed__imm_s__alu_op2 ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B4 Bool) (B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B4 Bool (true false (and B3 B3) (or B3 B3) (not B3) x0 x1 x2 x3))
(B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3))
(B0 Bool (true false x0 x1 x2 x3)))
        
)
        


(synth-fun hold_decode ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B4 Bool) (B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B4 Bool (true false (and B3 B3) (or B3 B3) (not B3) x0 x1 x2 x3))
(B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3))
(B0 Bool (true false x0 x1 x2 x3)))
        
)
        
(declare-var x0 Bool)
(declare-var x1 Bool)
(declare-var x2 Bool)
(declare-var x3 Bool)
(constraint (not (and (feed__imm_i__alu_op2 x0 x1 x2 x3) (feed__imm_s__alu_op2 x0 x1 x2 x3))))
(constraint (not (and (feed__imm_i__alu_op2 x0 x1 x2 x3) (hold_decode x0 x1 x2 x3))))
(constraint (not (and (feed__imm_s__alu_op2 x0 x1 x2 x3) (feed__imm_i__alu_op2 x0 x1 x2 x3))))
(constraint (not (and (feed__imm_s__alu_op2 x0 x1 x2 x3) (hold_decode x0 x1 x2 x3))))
(constraint (not (and (hold_decode x0 x1 x2 x3) (feed__imm_i__alu_op2 x0 x1 x2 x3))))
(constraint (not (and (hold_decode x0 x1 x2 x3) (feed__imm_s__alu_op2 x0 x1 x2 x3))))
(constraint (or (feed__imm_i__alu_op2 x0 x1 x2 x3) (feed__imm_s__alu_op2 x0 x1 x2 x3) (hold_decode x0 x1 x2 x3)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_i__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false true)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false true)))
(constraint (not (feed__imm_s__alu_op2 false true false true)))
(constraint (not (feed__imm_i__alu_op2 false true false false)))
(constraint (not (hold_decode false true false false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_i__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true true)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 false false true false)))
(constraint (not (hold_decode false false true false)))
(constraint (not (feed__imm_s__alu_op2 true false false false)))
(constraint (not (hold_decode true false false false)))

(check-synth)