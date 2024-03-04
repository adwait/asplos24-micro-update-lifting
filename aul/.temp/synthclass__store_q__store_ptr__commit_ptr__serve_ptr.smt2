(set-logic UF)
(synth-fun gen_make_store ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3 x4 x5 x6))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3 x4 x5 x6))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3 x4 x5 x6))
(B0 Bool (true false x0 x1 x2 x3 x4 x5 x6)))
        
)
        


(synth-fun gen_store_non_update ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3 x4 x5 x6))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3 x4 x5 x6))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3 x4 x5 x6))
(B0 Bool (true false x0 x1 x2 x3 x4 x5 x6)))
        
)
        


(synth-fun non_update_commit_ptr ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3 x4 x5 x6))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3 x4 x5 x6))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3 x4 x5 x6))
(B0 Bool (true false x0 x1 x2 x3 x4 x5 x6)))
        
)
        


(synth-fun non_update_serve_ptr ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3 x4 x5 x6))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3 x4 x5 x6))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3 x4 x5 x6))
(B0 Bool (true false x0 x1 x2 x3 x4 x5 x6)))
        
)
        


(synth-fun update_commit_ptr ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3 x4 x5 x6))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3 x4 x5 x6))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3 x4 x5 x6))
(B0 Bool (true false x0 x1 x2 x3 x4 x5 x6)))
        
)
        


(synth-fun update_serve_ptr ((x0 Bool) (x1 Bool) (x2 Bool) (x3 Bool) (x4 Bool) (x5 Bool) (x6 Bool)) Bool
    
    ;; Declare the non-terminals that would be used in the grammar
    ((B3 Bool) (B2 Bool) (B1 Bool) (B0 Bool))

    ;; Define the grammar for allowed implementations of max2
    ((B3 Bool (true false (and B2 B2) (or B2 B2) (not B2) x0 x1 x2 x3 x4 x5 x6))
(B2 Bool (true false (and B1 B1) (or B1 B1) (not B1) x0 x1 x2 x3 x4 x5 x6))
(B1 Bool (true false (and B0 B0) (or B0 B0) (not B0) x0 x1 x2 x3 x4 x5 x6))
(B0 Bool (true false x0 x1 x2 x3 x4 x5 x6)))
        
)
        
(declare-var x0 Bool)
(declare-var x1 Bool)
(declare-var x2 Bool)
(declare-var x3 Bool)
(declare-var x4 Bool)
(declare-var x5 Bool)
(declare-var x6 Bool)
(constraint (not (and (gen_make_store x0 x1 x2 x3 x4 x5 x6) (gen_store_non_update x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (gen_store_non_update x0 x1 x2 x3 x4 x5 x6) (gen_make_store x0 x1 x2 x3 x4 x5 x6))))
(constraint (or (gen_make_store x0 x1 x2 x3 x4 x5 x6) (gen_store_non_update x0 x1 x2 x3 x4 x5 x6)))
(constraint (not (and (gen_make_store x0 x1 x2 x3 x4 x5 x6) (gen_store_non_update x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (gen_store_non_update x0 x1 x2 x3 x4 x5 x6) (gen_make_store x0 x1 x2 x3 x4 x5 x6))))
(constraint (or (gen_make_store x0 x1 x2 x3 x4 x5 x6) (gen_store_non_update x0 x1 x2 x3 x4 x5 x6)))
(constraint (not (and (update_commit_ptr x0 x1 x2 x3 x4 x5 x6) (non_update_commit_ptr x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (non_update_commit_ptr x0 x1 x2 x3 x4 x5 x6) (update_commit_ptr x0 x1 x2 x3 x4 x5 x6))))
(constraint (or (update_commit_ptr x0 x1 x2 x3 x4 x5 x6) (non_update_commit_ptr x0 x1 x2 x3 x4 x5 x6)))
(constraint (not (and (update_serve_ptr x0 x1 x2 x3 x4 x5 x6) (non_update_serve_ptr x0 x1 x2 x3 x4 x5 x6))))
(constraint (not (and (non_update_serve_ptr x0 x1 x2 x3 x4 x5 x6) (update_serve_ptr x0 x1 x2 x3 x4 x5 x6))))
(constraint (or (update_serve_ptr x0 x1 x2 x3 x4 x5 x6) (non_update_serve_ptr x0 x1 x2 x3 x4 x5 x6)))
(constraint (not (gen_store_non_update true false false false false false true)))
(constraint (not (update_commit_ptr true false false false false false true)))
(constraint (not (update_serve_ptr true false false false false false true)))
(constraint (not (gen_make_store false true false false false false true)))
(constraint (not (non_update_commit_ptr false true false false false false true)))
(constraint (not (update_serve_ptr false true false false false false true)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_store_non_update true false true false true false false)))
(constraint (not (non_update_serve_ptr true false true false true false false)))
(constraint (not (update_commit_ptr true false true false true false false)))
(constraint (not (gen_make_store false true true false false false true)))
(constraint (not (non_update_commit_ptr false true true false false false true)))
(constraint (not (update_serve_ptr false true true false false false true)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_store_non_update true false true false true false false)))
(constraint (not (non_update_serve_ptr true false true false true false false)))
(constraint (not (update_commit_ptr true false true false true false false)))
(constraint (not (gen_make_store false true true false false false true)))
(constraint (not (non_update_commit_ptr false true true false false false true)))
(constraint (not (update_serve_ptr false true true false false false true)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_store_non_update true false true false true false false)))
(constraint (not (non_update_serve_ptr true false true false true false false)))
(constraint (not (update_commit_ptr true false true false true false false)))
(constraint (not (gen_make_store false true true false false false true)))
(constraint (not (non_update_commit_ptr false true true false false false true)))
(constraint (not (update_serve_ptr false true true false false false true)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_store_non_update true false true false true false false)))
(constraint (not (non_update_serve_ptr true false true false true false false)))
(constraint (not (update_commit_ptr true false true false true false false)))
(constraint (not (gen_make_store false true false false false false true)))
(constraint (not (non_update_commit_ptr false true false false false false true)))
(constraint (not (update_serve_ptr false true false false false false true)))
(constraint (not (gen_make_store false false true false true false false)))
(constraint (not (non_update_serve_ptr false false true false true false false)))
(constraint (not (update_commit_ptr false false true false true false false)))
(constraint (not (gen_make_store false true false false false false true)))
(constraint (not (non_update_commit_ptr false true false false false false true)))
(constraint (not (update_serve_ptr false true false false false false true)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_store_non_update true false false false true false false)))
(constraint (not (update_commit_ptr true false false false true false false)))
(constraint (not (update_serve_ptr true false false false true false false)))
(constraint (not (gen_make_store false true false false true false false)))
(constraint (not (non_update_commit_ptr false true false false true false false)))
(constraint (not (update_serve_ptr false true false false true false false)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))
(constraint (not (gen_store_non_update true false false false true false false)))
(constraint (not (update_commit_ptr true false false false true false false)))
(constraint (not (update_serve_ptr true false false false true false false)))
(constraint (not (gen_make_store false true false false true false false)))
(constraint (not (non_update_commit_ptr false true false false true false false)))
(constraint (not (update_serve_ptr false true false false true false false)))
(constraint (not (gen_make_store false false true false true false false)))
(constraint (not (non_update_serve_ptr false false true false true false false)))
(constraint (not (update_commit_ptr false false true false true false false)))
(constraint (not (gen_store_non_update true false false false true false false)))
(constraint (not (update_commit_ptr true false false false true false false)))
(constraint (not (update_serve_ptr true false false false true false false)))
(constraint (not (gen_make_store false true false false true false false)))
(constraint (not (non_update_commit_ptr false true false false true false false)))
(constraint (not (update_serve_ptr false true false false true false false)))
(constraint (not (gen_make_store false false false false true false false)))
(constraint (not (update_commit_ptr false false false false true false false)))
(constraint (not (update_serve_ptr false false false false true false false)))

(check-synth)