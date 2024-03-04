(set-logic UF)
(synth-fun feed__mem_reg_wbaddr__reg_rd_addr_in ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1 x2 x3 x4 x5 x6) ) )
)
        
(declare-var x0 Bool)
(declare-var x1 Bool)
(declare-var x2 Bool)
(declare-var x3 Bool)
(declare-var x4 Bool)
(declare-var x5 Bool)
(declare-var x6 Bool)
(constraint (or (feed__mem_reg_wbaddr__reg_rd_addr_in x0 x1 x2 x3 x4 x5 x6)))


(check-synth)