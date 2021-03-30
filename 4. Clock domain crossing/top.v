`define COUNTER 21
`define UPDATER 16
`define SEND_SIGNAL `COUNTER - 4
`define CLKA 10
`define CLKB 10

module top 
(
    input wire CLK,
    output DS_EN1, DS_EN2, DS_EN3, DS_EN4,
    output DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G
);

// Clock initialization
    wire timer_counter;
    wire timer_updater;
	 wire timer_sendler;
	 wire clka;
	 wire clkb;
	 
    time_counter #(`COUNTER)     Counter( .clk(CLK), .timer(timer_counter));  // link (system timer -> timer_counter) for seconds counter
    time_counter #(`UPDATER)     Updater( .clk(CLK), .timer(timer_updater));  // link (system timer -> timer_updater) for seconds counter
	 time_counter #(`SEND_SIGNAL) Sendler( .clk(CLK), .timer(timer_sendler));  // link (system timer -> timer_sendler) for seconds counter
	 time_counter #(`CLKA)        Clk_a  ( .clk(CLK), .timer(clka));           // link (system timer -> clka)          for seconds counter
	 time_counter #(`CLKB)        Clk_b  ( .clk(CLK), .timer(clkb));           // link (system timer -> clkb)          for seconds counter
	 
// Gray counter
    wire [15:0] grey_counter;
    reg  [3:0]  grey_address = 0;
	 
	 rom grey_data(.clock(timer_counter), .address(grey_address), .q(grey_counter));
	 
    always @(posedge timer_counter) 
    begin
        grey_address <= grey_address + 1;
    end
	 
// Resynchronizer
    wire [15:0] sync_data;
    reg aready;
	 
    resynchronizer clkdmncrossing( .clka(clka), .clkb(clkb),
                                   .data_input(grey_counter), .asend(timer_sendler), .aready(aready), .bout(sync_data));
						
// grey_counter -> 7Segments data-register
    reg [27:0] segments;

    hex2seg Hex2seg1( .hex(sync_data[3:0]),   .seg(segments[6:0]));      // hex -> seg
    hex2seg Hex2seg2( .hex(sync_data[7:4]),   .seg(segments[13:7]));     // hex -> seg
    hex2seg Hex2seg3( .hex(sync_data[11:8]),  .seg(segments[20:14]));    // hex -> seg
    hex2seg Hex2seg4( .hex(sync_data[15:12]), .seg(segments[27:21]));    // hex -> seg
	 
// 7Segment indacator output
    wire [6:0] linker_segment;
    wire [3:0] current_cell;
    
    numbers_output Output( .clk(timer_updater), .segment1(segments[6:0]), .segment2(segments[13:7]),
                           .segment3(segments[20:14]), .segment4(segments[27:21]), .linker_segment(linker_segment),
                           .current_cell(current_cell));
                                  
    assign {DS_A, DS_B, DS_C, DS_D, DS_E, DS_F, DS_G} = linker_segment;
    assign {DS_EN1, DS_EN2, DS_EN3, DS_EN4}           = current_cell;

endmodule