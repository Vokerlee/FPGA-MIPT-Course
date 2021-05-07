`define UPDATER 12

module top
(
    input wire CLK,
    output DS_EN1, DS_EN2, DS_EN3, DS_EN4,
    output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);

    wire ready_flag;
    wire jmp_flag;
    wire [1:0] command_size;

    wire [31:00] new_exe_addr;
    wire [95:0] cmd_args;
    wire [95:0] cmd_args_reversed;
	 
    genvar i;

    generate
        for (i = 0; i < 3; i = i + 1)
        begin : reverseGen
            assign cmd_args_reversed[07 + i * 32 : 00 + i * 32] = cmd_args[31 + i * 32 : 24 + i * 32];
            assign cmd_args_reversed[15 + i * 32 : 08 + i * 32] = cmd_args[23 + i * 32 : 16 + i * 32];
            assign cmd_args_reversed[23 + i * 32 : 16 + i * 32] = cmd_args[15 + i * 32 : 08 + i * 32];
            assign cmd_args_reversed[31 + i * 32 : 24 + i * 32] = cmd_args[07 + i * 32 : 00 + i * 32];
        end
    endgenerate

    wire [5:0] cmd_flags;

    wire exe_flag;

    wire [127:0] dump;

/* testable modules */

    executor executor (.clk(CLK), .exe_flag(exe_flag), .cmd_flags(cmd_flags), .cmd_args(cmd_args_reversed), 
                       .ready_flag(ready_flag), .jmp_flag(jmp_flag), .new_exe_addr_offset(new_exe_addr), .dump (dump));

    fetcher ftchr (.clk(CLK), .prev_cmd_size(command_size), .ready_flag(ready_flag),
                   .jmp_flag(jmp_flag), .new_exe_addr_offset(new_exe_addr),
                   .cmd_arguments(cmd_args), .exe_flag(exe_flag));

    decoder dcdr (.cmd_code(cmd_args_reversed[7:0]), .cmd_size(command_size), .cmd_flags(cmd_flags));
	 
// Clock initialization

    wire timer_updater;
    time_counter #(`UPDATER) Updater( .clk(CLK), .timer(timer_updater));  // link (system timer -> time_updater) for seconds counter
						
// 7Segment data-registers initialization

    reg [6:0] segment1 = 0;
    reg [6:0] segment2 = 0;
    reg [6:0] segment3 = 0;
    reg [6:0] segment4 = 0;

    hex2seg Hex2seg1( .hex(dump[7:0]),    .seg(segment1));      // hex -> seg
    hex2seg Hex2seg2( .hex(dump[39:32]),  .seg(segment2));      // hex -> seg
    hex2seg Hex2seg3( .hex(dump[71:64]),  .seg(segment3));      // hex -> seg
    hex2seg Hex2seg4( .hex(dump[103:96]), .seg(segment4));      // hex -> seg
	 
// 7Segment indacator output

    wire [6:0] linker_segment;
    wire [3:0] current_cell;
    
    numbers_output Output( .clk(timer_updater), .segment1(segment1), .segment2(segment2),
                           .segment3(segment3), .segment4(segment4), .linker_segment(linker_segment),
                           .current_cell(current_cell));
                                  
    assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = linker_segment;
    assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4}           = current_cell;

endmodule
