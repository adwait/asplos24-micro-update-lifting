(set-logic UF)
(synth-fun feed__dec_wbaddr__exe_reg_wbaddr ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1 x2 x3 x4 x5 x6) ) )
)
        


(synth-fun zero__exe_reg_wbaddr ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

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
(constraint (not (and (feed__dec_wbaddr__exe_reg_wbaddr x0 x1 x2 x3 x4 x5 x6) (zero__exe_reg_wbaddr x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (zero__exe_reg_wbaddr x0 x1 x2 x3 x4 x5 x6) (feed__dec_wbaddr__exe_reg_wbaddr x0 x1 x2 x3 x4 x5 x6))))
(constraint (or (feed__dec_wbaddr__exe_reg_wbaddr x0 x1 x2 x3 x4 x5 x6) (zero__exe_reg_wbaddr x0 x1 x2 x3 x4 x5 x6)))
(constraint (not (zero__exe_reg_wbaddr true false true false true false true)))
(constraint (not (zero__exe_reg_wbaddr true false true true false true false)))
(constraint (not (zero__exe_reg_wbaddr true false true false true false true)))
(constraint (not (zero__exe_reg_wbaddr true false true true false true false)))
(constraint (not (zero__exe_reg_wbaddr true false true false true false true)))
(constraint (not (zero__exe_reg_wbaddr false true false true false true false)))
(constraint (not (zero__exe_reg_wbaddr true false true true true false true)))
(constraint (not (zero__exe_reg_wbaddr true true false true true true false)))
(constraint (not (zero__exe_reg_wbaddr false false false true false true true)))
(constraint (not (zero__exe_reg_wbaddr true false false false true false false)))
(constraint (not (zero__exe_reg_wbaddr true false true false true false true)))
(constraint (not (zero__exe_reg_wbaddr true false true false true false true)))
(constraint (not (zero__exe_reg_wbaddr true false true true false true false)))

(check-synth)