`include "dlatch.v"

module d_flip_flop
(
    input d,
    input e,
    output q,
    output notq
);
    
    wire q_master; 
    wire notq_master;

    wire not_e = ~e;

    d_latch d_latch_master(.d(d), .e(not_e), .q(q_master), .notq(notq_master));

    wire d_slave = q_master;
    wire e_slave = e; 

    d_latch d_latch_slave(.d(d_slave), .e(e_slave), .q(q), .notq(notq));

endmodule
