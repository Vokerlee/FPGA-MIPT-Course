module fetcher
(
    input wire clk,
    input wire ready_flag,                                      // the signal that tells if the executor needs the next command

    input wire [1:0] prev_cmd_size,                             // to know next command address
    input wire jmp_flag,                                        // to know if the fetcher should change execution address
    
    input wire [31:0] new_exe_addr_offset,                      // new execution-address offset

    output wire [32 * 3 - 1:0] cmd_arguments,                   // commands info for executor & decoder
    output reg exe_flag
);

    reg [31:0] ip;                                              // instruction pointer                   

    initial begin
        ip       = 0;
        exe_flag = 0;
    end

    /* code segment reading stuff */
    rom code_segment (.address(ip), .data(cmd_arguments));

    always @(posedge clk)
    begin
        if (ready_flag)                                         // need to change ip
        begin
            if (jmp_flag)
                ip <= ip + new_exe_addr_offset;
            else
                ip <= ip + prev_cmd_size;
        end
    end

    always @(posedge clk) 
    begin
        if (~ready_flag && ~exe_flag)
            exe_flag <= 1;
        if (ready_flag)                                         // exe is free and it is a time to begin to pass the next command
            exe_flag <= 0;
    end


endmodule