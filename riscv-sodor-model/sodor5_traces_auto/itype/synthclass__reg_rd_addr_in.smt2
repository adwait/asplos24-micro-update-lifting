(set-logic UF)
(synth-fun feed__mem_reg_wbaddr__reg_rd_addr_in ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3))
(B0 Bool (true false x0 x1 x2 x3)))
        
)
        
(declare-var x0 Bool)
(declare-var x1 Bool)
(declare-var x2 Bool)
(declare-var x3 Bool)
(constraint (or (feed__mem_reg_wbaddr__reg_rd_addr_in x0 x1 x2 x3)))


(check-synth)