module rom
#(
    parameter address_size = 32,    // 32 bits
    parameter word_size    = 32,    // 32 bits
    parameter n_words      = 128,
    parameter input_name   = "compiled_code.txt"
)
(
    input  wire [address_size - 1:0] address,
    output wire [word_size * 3 - 1:0] data 	// read data (no more than 3 value in commmand)
);

    // ROM
    reg [word_size - 1:0] memory[n_words - 1:0];

    initial begin
        $readmemh (input_name, memory);
    end

    // Read the data of the given address
    assign data = memory[address] + (memory[address + 1] << word_size) + (memory[address + 2] << (word_size * 2));

endmodule