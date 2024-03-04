(set-logic UF)
(synth-fun feed__imm__reg_rd_data_in ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1 x2 x3 x4 x5 x6) ) )
)
        


(synth-fun feed__reg_rs1_data_out__reg_rd_data_in ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1 x2 x3 x4 x5 x6) ) )
)
        


(synth-fun feed__reg_rs2_data_out__reg_rd_data_in ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1 x2 x3 x4 x5 x6) ) )
)
        


(synth-fun feed__alu_out__reg_rd_data_in ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

    ;; Declare the non-terminals that would be used in the grammar
    ((B Bool))

    ;; Define the grammar for allowed implementations of max2
    ( (B Bool (true false (and B B) (or B B) (not B) x0 x1 x2 x3 x4 x5 x6) ) )
)
        


(synth-fun feed__mem_reg_alu_out__reg_rd_data_in ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool

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
(constraint (not (and (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6))))
(constraint (or (feed__imm__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs1_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__reg_rs2_data_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6) (feed__mem_reg_alu_out__reg_rd_data_in x0 x1 x2 x3 x4 x5 x6)))
(constraint (not (feed__imm__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__alu_out__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__imm__reg_rd_data_in true false true true false true false)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in true false true true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__imm__reg_rd_data_in true false true true false true false)))
(constraint (not (feed__alu_out__reg_rd_data_in true false true true false true false)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false true true false true false)))
(constraint (not (feed__imm__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__imm__reg_rd_data_in false true false true false true false)))
(constraint (not (feed__alu_out__reg_rd_data_in false true false true false true false)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in false true false true false true false)))
(constraint (not (feed__imm__reg_rd_data_in true false true true true false true)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in false true false true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in false true false true false true false)))
(constraint (not (feed__alu_out__reg_rd_data_in false true false true false true false)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in false true false true false true false)))
(constraint (not (feed__imm__reg_rd_data_in true false true true true false true)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in true false true true true false true)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false true true true false true)))
(constraint (not (feed__alu_out__reg_rd_data_in true false true true true false true)))
(constraint (not (feed__imm__reg_rd_data_in true true false true true true false)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in false false false true false true true)))
(constraint (not (feed__alu_out__reg_rd_data_in false false false true false true true)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in false false false true false true true)))
(constraint (not (feed__imm__reg_rd_data_in false false false false false false true)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in false false false false false false true)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in false false false false false false true)))
(constraint (not (feed__alu_out__reg_rd_data_in false false false false false false true)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false false false true false false)))
(constraint (not (feed__alu_out__reg_rd_data_in true false false false true false false)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false false false true false false)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in false false false true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in false false false true false true false)))
(constraint (not (feed__alu_out__reg_rd_data_in false false false true false true false)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in false false false true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__alu_out__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false false true false true false)))
(constraint (not (feed__reg_rs2_data_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false true false true false true)))
(constraint (not (feed__imm__reg_rd_data_in true false true true false true false)))
(constraint (not (feed__reg_rs1_data_out__reg_rd_data_in true false true true false true false)))
(constraint (not (feed__mem_reg_alu_out__reg_rd_data_in true false true true false true false)))

(check-synth)