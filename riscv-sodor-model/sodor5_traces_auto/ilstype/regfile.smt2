(set-logic UF)
(synth-fun regs_write ((x0 Bool) (x1 Bool) (x2 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B4 Bool) (B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B4 Bool (true false (and B3 B3) (or B3 B3) (not B3) x0 x1 x2))
(B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2))
(B0 Bool (true false x0 x1 x2)))
        
)
        


(synth-fun no_regs_write ((x0 Bool) (x1 Bool) (x2 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B4 Bool) (B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B4 Bool (true false (and B3 B3) (or B3 B3) (not B3) x0 x1 x2))
(B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2))
(B0 Bool (true false x0 x1 x2)))
        
)
        
(declare-var x0 Bool)
(declare-var x1 Bool)
(declare-var x2 Bool)
(constraint (not (and (regs_write x0 x1 x2) (no_regs_write x0 x1 x2))))
(constraint (not (and (no_regs_write x0 x1 x2) (regs_write x0 x1 x2))))
(constraint (or (regs_write x0 x1 x2) (no_regs_write x0 x1 x2)))
(constraint (not (regs_write false true false)))
(constraint (not (regs_write false true false)))
(constraint (not (regs_write false true false)))
(constraint (not (regs_write false true false)))
(constraint (not (no_regs_write false false false)))
(constraint (not (regs_write false true false)))
(constraint (not (regs_write false true false)))
(constraint (not (regs_write false true false)))
(constraint (not (regs_write false true false)))
(constraint (not (no_regs_write false false false)))
(constraint (not (regs_write false true false)))

(check-synth)