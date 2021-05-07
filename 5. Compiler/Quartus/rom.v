module rom
(
    input  wire [31:0] address,
    output wire [32 * 3 - 1:0] data 	// read data (no more than 3 value in commmand)
);
    // ROM
    reg [31:0] memory[58 - 1:0];

    initial begin
        $readmemh ("compiled_code.txt", memory);
    end

    // Read the data of the given address
    assign data = memory[address] + (memory[address + 1] << 32) + (memory[address + 2] << 64);

endmodule