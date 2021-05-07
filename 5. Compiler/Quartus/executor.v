module executor
#(
    parameter address_size = 32,	// 32 bits
    parameter word_size    = 32 	// 32 bits
)
(
    input wire clk,
    input wire exe_flag,

    input wire [5:0] cmd_flags,
    input wire [word_size * 3 - 1:0] cmd_args,

    output reg ready_flag = 0,                                  // (for fetcher) ready to execute next cmd flag
    output reg jmp_flag   = 0,                                  // (for fetcher)

    output wire [address_size - 1:0] new_exe_addr_offset,
    output wire [word_size * 4 - 1:0] dump
);

// JMP ADDRESS
    assign new_exe_addr_offset = cmd_args [word_size * 2 - 1 : word_size];          // if cmd is jump

// MOV CMD
    // WRITE
    wire [word_size - 1:0] write_num = cmd_args[2 * word_size - 1:32]; 
    wire [07:0] write_reg = cmd_args[15:08];
    wire write_num_regime = cmd_args[16:16];
    wire write_mem_regime = cmd_args[17:17];

    // READ
    wire [word_size - 1:0] read_num = cmd_args[95:64];
    wire [07:0] read_reg = cmd_args[27:20];
    wire read_num_regime = cmd_args[28:28];
    wire read_mem_regime = cmd_args[29:29];

    wire [1:0] read_regime;
    assign read_regime[1] = read_mem_regime;
    assign read_regime[0] = read_num_regime;

// COMMANDS' FLAGS
    wire mov_cmd_flag = cmd_flags[5:5];
    wire add_cmd_flag = cmd_flags[4:4];
    wire cmp_cmd_flag = cmd_flags[3:3];

    wire jmp_cmd_flag = cmd_flags[2:2];
    wire je_cmd_flag  = cmd_flags[1:1];
    wire ja_cmd_flag  = cmd_flags[0:0];

// CMP FLAGS
    reg eq_flag = 0;
    reg a_flag = 0;         // a  = above (for ja cmd)

// REGISTERS
    reg [word_size - 1:0] registers[31:0];

// RAM
    reg [word_size - 1:0] memory[15:0];

// FOR DUMP
    assign dump [31:0]   = memory[0];
    assign dump [63:32]  = memory[1];
    assign dump [95:64]  = memory[2];
    assign dump [127:96] = memory[3];

// REGS & MEM WRITES STUFF
    reg reg_write_flag = 0;
    reg mem_write_flag = 0;

    // TEMP BUFFERS
    reg [word_size - 1:0] reg_wr_buffer = 0;
    reg [word_size - 1:0] mem_wr_buffer = 0;

    // Reg write id & mem write addr
    reg [4:0] reg_wr_id = 0;
    reg [address_size - 1:0] mem_wr_addr = 0;

// INITIALIZATION
    initial 
    begin
        eq_flag = 0;
        a_flag = 0;

        reg_write_flag = 0;
        mem_write_flag = 0;

        reg_wr_buffer = 0;
        mem_wr_buffer = 0;

        reg_wr_id   = 0;
        mem_wr_addr = 0;

        $readmemh ("memory.txt", registers);
        $readmemh ("memory.txt", memory);
    end

// READY FLAG
    always @(negedge clk) 
    begin
        if (exe_flag && ~ready_flag)
        begin
            ready_flag <= jmp_cmd_flag || je_cmd_flag  || ja_cmd_flag || cmp_cmd_flag || reg_write_flag || mem_write_flag;
        end
        else 
            ready_flag <= 0;
    end

// JUMPS
    always @(negedge clk)
    begin
        if (exe_flag)
            jmp_flag <= jmp_cmd_flag || (je_cmd_flag && eq_flag) || (ja_cmd_flag && a_flag);
        else
            jmp_flag <= 0;

    end

// CMP
    always @(negedge clk)
    begin
        if (exe_flag && cmp_cmd_flag)
        begin
            if (registers [cmd_args[15:08]] > registers[cmd_args [23:16]])
            begin
                a_flag <= 1;
            end
            else
            begin
                a_flag <= 0;
            end
        end
    end

    always @(negedge clk)
    begin
        if (exe_flag && cmp_cmd_flag)
        begin
            if (registers [cmd_args[15:08]] === registers[cmd_args[23:16]])
            begin
                eq_flag <= 1;
            end
            else begin
                eq_flag <= 0;
            end

        end
    end

// ADD & MOV
    always @(negedge clk)
    begin
        if (exe_flag && (add_cmd_flag || mov_cmd_flag))
        begin
            if (add_cmd_flag)
                reg_wr_buffer <= registers[cmd_args[15:08]] + registers[cmd_args[23:16]];
                
            if (mov_cmd_flag)
                if (~write_mem_regime)
                begin
                    if (read_regime === 2'b00) reg_wr_buffer <= registers[read_reg];
                    else if (read_regime === 2'b01) reg_wr_buffer <= read_num;
                    else if (read_regime === 2'b10) reg_wr_buffer <= memory[registers[read_reg]]; 
                    else if (read_regime === 2'b11) reg_wr_buffer <= memory[read_num];
                end
        end
    end

    always @(negedge clk)
    begin
        if (exe_flag && (add_cmd_flag || mov_cmd_flag))
        begin
            if (add_cmd_flag)
                reg_wr_id <= cmd_args [31 : 24];
            if (mov_cmd_flag && ~write_mem_regime)
                reg_wr_id <= write_reg;
        end
    end

    always @(negedge clk)
    begin
        if (exe_flag && mov_cmd_flag)
        begin
            if (write_mem_regime)
            begin
                if (read_regime === 2'b00)     
                    mem_wr_buffer <= registers [read_reg];
                else if (read_regime === 2'b01)
                    mem_wr_buffer <= read_num;
                else if (read_regime === 2'b10) 
                    mem_wr_buffer <= memory  [registers [read_reg]];
                else if (read_regime === 2'b11)
                    mem_wr_buffer <= memory  [read_num];
            end
        end
    end

    always @(negedge clk)
    begin
        if (exe_flag && mov_cmd_flag)
        begin
            if (write_mem_regime)
            begin
                if (write_num_regime)
                    mem_wr_addr <= write_num;
                else
                    mem_wr_addr <= registers [write_reg];
            end
        end
    end

    // Reg & mem write
    always @(negedge clk)
    begin
        if (mem_write_flag)
            memory [mem_wr_addr] <= mem_wr_buffer;
    end

    always @(negedge clk)
    begin
        if (reg_write_flag)
            registers [reg_wr_id] <= reg_wr_buffer;
    end

    // Update mem and reg write flags
    always @(negedge clk)
    begin
        if (~reg_write_flag && ~ready_flag)
            reg_write_flag <= add_cmd_flag || (mov_cmd_flag && ~write_mem_regime);
        else
            reg_write_flag <= 0;
    end

    always @(negedge clk)
    begin
        if (~mem_write_flag && ~ready_flag)
            mem_write_flag <= mov_cmd_flag && write_mem_regime;
        else
            mem_write_flag <= 0;
    end
    

endmodule