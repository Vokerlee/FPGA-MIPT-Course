module time_updater
(
    input wire clk,
    output wire timer
);

    reg [11:0] cnt;
    assign timer = cnt[11];

    always @(posedge clk)
    begin
        cnt <= (cnt === {12{1'b1}}) ? 12'h0 : cnt + 12'h1;
    end

endmodule
