module time_counter #(parameter divider)
(
    input wire clk,
    output wire timer
);

    reg [divider - 1:0] counter;
    assign timer = counter[divider - 1];

    always @(posedge clk)
    begin
        counter <= (counter === {divider{1'b1}}) ? 0 : counter + 1;
    end

endmodule