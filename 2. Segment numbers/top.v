module top
(
    input CLK,
    output DS_EN1, DS_EN2, DS_EN3, DS_EN4,
    output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);
    wire timer_counter;
    wire timer_updater;
    
    time_counter Clkdiv1( .clk(CLK), .timer(timer_counter));  // link (system timer -> clkdiv)  for seconds counter
    time_updater Clkdiv2( .clk(CLK), .timer(timer_updater));  // link (system timer -> clk_num) for seconds counter

    reg [15:0] num_counter = 0;
    hex_counter Cnthex1( .clk(timer_counter), .hex(num_counter) );    // launch (timer -> hex_counter)

    reg [6:0] segment1 = 0;
    reg [6:0] segment2 = 0;
    reg [6:0] segment3 = 0;
    reg [6:0] segment4 = 0;

    hex2seg Hex2seg1( .hex(num_counter[3:0]),   .seg(segment1));      // hex -> seg
    hex2seg Hex2seg2( .hex(num_counter[7:4]),   .seg(segment2));      // hex -> seg
    hex2seg Hex2seg3( .hex(num_counter[11:8]),  .seg(segment3));      // hex -> seg
    hex2seg Hex2seg4( .hex(num_counter[15:12]), .seg(segment4));      // hex -> seg

    wire [6:0] linker_segment;
    wire [3:0] current_cell;
    
    numbers_output Output( .clk(timer_updater), .segment1(segment1), .segment2(segment2),
                                  .segment3(segment3), .segment4(segment4), .linker_segment(linker_segment),
                                  .current_cell(current_cell));
                                  
    assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = linker_segment;
    assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4}           = current_cell;

endmodule
