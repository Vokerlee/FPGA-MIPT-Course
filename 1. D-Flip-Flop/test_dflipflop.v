`timescale 1 ns / 100 ps

module test_d_flip_flop(); /* No inputs, no outputs */

reg d = 1'b1; /* Represents clock, initial value is 0 */
reg e = 1'b0; /* Represents clock, initial value is 0 */

always begin
    #1.32 d = ~d; /* Toggle clock every 1ns */
end

always begin
    #2 e = ~e;
end

wire q; /* For output of tested module */
wire notq; /* For output of tested module */

d_flip_flop d_flip_flop(.d(d), .e(e), .q(q), .notq(notq)); /* Tested module instance */

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("Test started...");   /* Write to console */
    #16 $finish;    /* Stop simulation after 10ns */
end

endmodule