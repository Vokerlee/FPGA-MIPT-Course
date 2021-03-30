`include "srlatch.v"

module d_latch (input d, input e, output q, output notq);
    
    wire r; 
    wire s;

    and(s, d, e);
    and(r, ~d, e);

    sr_latch sr_latch(.s(r), .r(s), .q(q), .notq(notq));

endmodule