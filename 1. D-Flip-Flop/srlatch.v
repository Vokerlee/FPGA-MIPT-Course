module sr_latch (input s, input r, output q, output notq);

    nor(q, s, notq);
    nor(notq, r, q);
    
endmodule