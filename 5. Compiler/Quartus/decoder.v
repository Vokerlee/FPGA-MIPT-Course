`define MOV_CODE 11
`define ADD_CODE 18
`define CMP_CODE 67

`define JMP_CODE 74
`define JEQ_CODE 69
`define JGG_CODE 71

module decoder
(
    input wire  [7:0] cmd_code,
    output reg  [1:0] cmd_size  = 0,
    output reg  [5:0] cmd_flags = 0

);
    always @(*)
    begin
        case (cmd_code)

            `MOV_CODE: cmd_size = 2'b11;
            `ADD_CODE: cmd_size = 2'b01;
            `CMP_CODE: cmd_size = 2'b01;

            `JMP_CODE: cmd_size = 2'b10;
            `JEQ_CODE: cmd_size = 2'b10;
            `JGG_CODE: cmd_size = 2'b10;

        endcase
    end

    always @(*)
    begin
        case (cmd_code)

            `MOV_CODE: cmd_flags = 6'b100000;
            `ADD_CODE: cmd_flags = 6'b010000;
            `CMP_CODE: cmd_flags = 6'b001000;

            `JMP_CODE: cmd_flags = 6'b000100;
            `JEQ_CODE: cmd_flags = 6'b000010;
            `JGG_CODE: cmd_flags = 6'b000001;

        endcase
    end

endmodule