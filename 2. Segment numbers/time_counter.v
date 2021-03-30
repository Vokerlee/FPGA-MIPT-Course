module time_counter
(
    input wire clk,
    output wire timer
);

    reg [19:0]cnt;
    assign timer = cnt[19];

    always @(posedge clk)
    begin
        cnt <= (cnt === {20{1'b1}}) ? 20'h0 : cnt + 20'h1;
    end

endmodule
