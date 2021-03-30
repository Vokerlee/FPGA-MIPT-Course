module numbers_output(
    input clk,
    
    input [6:0] segment1,
    input [6:0] segment2,
    input [6:0] segment3,
    input [6:0] segment4,
    
    output reg [6:0] linker_segment = 0,
    output reg [3:0] current_cell   = 0
);

    reg [1:0] update = 0;

    always @(posedge clk)
    begin
        update <= (update === 2'b11) ? 2'b00 : update + 2'b01;
    end
    
    always @(posedge clk)
    begin
        case (update)
            2'b00:
                linker_segment <= segment4;
            2'b01:
                linker_segment <= segment3;
            2'b10:
                linker_segment <= segment2;
            default:
                linker_segment <= segment1;
        endcase
    end
    
    always @(posedge clk)
    begin
        case (update)
            2'b00:
                current_cell <= 4'b0111;
            2'b01:
                current_cell <= 4'b1011;
            2'b10:
                current_cell <= 4'b1101;
            default:
                current_cell <= 4'b1110;
        endcase
    end

endmodule