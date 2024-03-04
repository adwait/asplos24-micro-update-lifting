(set-logic UF)
(synth-fun feed__alu_out__mem_reg_alu_out ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B4 Bool) (B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B4 Bool (true false (and B3 B3) (or B3 B3) (not B3) x0 x1 x2 x3 x4 x5))
(B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3 x4 x5))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3 x4 x5))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3 x4 x5))
(B0 Bool (true false x0 x1 x2 x3 x4 x5)))
        
)
        
(declare-var x0 Bool)
(declare-var x1 Bool)
(declare-var x2 Bool)
(declare-var x3 Bool)
(declare-var x4 Bool)
(declare-var x5 Bool)
(constraint (or (feed__alu_out__mem_reg_alu_out x0 x1 x2 x3 x4 x5)))


(check-synth)