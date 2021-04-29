#include "compiler.h"
#include "config.h"

void compile(text_t* text, FILE* res)
{
    FILE* log          = fopen("log_compile.txt",  "wb");
    FILE* file_listing = fopen("file_listing.txt", "wb");

    assert(res);
    assert(log);
    assert(file_listing);
    assert(text);

    print_file_listing_header(file_listing);

    char* asm_buffer = (char*) calloc((sizeof(int) + sizeof(double)) * text->n_real_lines, sizeof(char));
    assert(asm_buffer);

    int bytes_buffer = 0;

    for (size_t i = 0; i < text->n_real_lines; i++)
    {
        fprintf(file_listing, "%08x: ", bytes_buffer);

        int error_state = process_line(asm_buffer, &bytes_buffer, &(text->lines[i]), file_listing);

        if (error_state == ERROR_FORMAT)
            fprintf(log, "ERROR FORMATTING OF CODE IN COMMAND %Iu\n", text->lines[i].real_num_line);
        else if (error_state == ERROR_UNKNOWN_CMD)
            fprintf(log, "UNKNOWN COMMAND %Iu\n", text->lines[i].real_num_line);
    }

    fwrite(&bytes_buffer, sizeof(int), 1, res);
    fwrite(asm_buffer, sizeof(char), bytes_buffer, res);

    free(asm_buffer);
}

void print_file_listing_header(FILE* file_listing)
{
    assert(file_listing);

    fprintf(file_listing, "File-listing:\n"
        "code %*.c ->", FILE_LISTING_INDENT / 2, ' ');

    fprintf(file_listing, "%*.c compiled_code\n", FILE_LISTING_INDENT / 2 + FILE_LISTING_INDENT % 2 + 2, ' ');
}

int process_line(char* asm_buffer, int* bytes_buffer, line_t* line, FILE* file_listing)
{
    assert(asm_buffer);
    assert(bytes_buffer);
    assert(line);
    assert(file_listing);

    char* command = (char*) calloc(line->length + 1, sizeof(char));
    char regist1  = 0;
    char regist2  = 0;
    char regist3  = 0;
    int number    = 0;

    int read_state = read_command(line, command, &regist1, &regist2, &regist3, &number);
    printf("%s: r1 = %d, r2 = %d, r3 = %d, number = %d\nstate = %d\n\n", command, regist1, regist2, regist3, number, read_state);

    if (read_state == ERROR_READ)
        return ERROR_FORMAT;
    else
    {
        int command_number = hash_search(hash_text(command));

        if (command_number == ERROR_HASH)
            return ERROR_UNKNOWN_CMD;
        else if (read_state == ARGUMENT_CMD)
            process_argument_cmd_line(asm_buffer, bytes_buffer, command, command_number, number, file_listing);
        else if (read_state == NO_ARGUMENT_CMD)
            process_no_argument_cmd_line(asm_buffer, bytes_buffer, command, command_number, file_listing);
        else if (read_state == TWO_REG)
            process_2_regs_cmd_line(asm_buffer, bytes_buffer, command, command_number, regist1, regist2, file_listing);
        else if (read_state == SEC_ARGUMENT_CMD)
            process_reg_sec_cmd_line(asm_buffer, bytes_buffer, command, command_number, regist1, number, file_listing);
        else if (read_state == THREE_REG)
            process_3_regs_cmd_line(asm_buffer, bytes_buffer, command, command_number, regist1, regist2, regist3, file_listing);
    }

    free(command);

    return 0;
}

int read_command(line_t* line, char* command, char* regist1, char* regist2, char* regist3, int* number)
{
    assert(line);
    assert(command);
    assert(number);

    int number_sign = 1;

    int counter = 0;

    if (!isalpha(line->line[counter]))
        return ERROR_READ;

    for (counter = 0; !isspace(line->line[counter]) && counter < line->length; counter++)
        command[counter] = line->line[counter];

    while (line->line[counter] == ' ' || line->line[counter] == '\t')
        counter++;

    if (counter >= line->length)
        return NO_ARGUMENT_CMD;

    if (isdigit(line->line[counter]) || (line->line[counter] == '-' && isdigit(line->line[counter + 1])))
    {
        *number = atoi(&(line->line[counter]));

        return ARGUMENT_CMD;
    }

    if (isalpha(line->line[counter]))
    {
        if (line->line[counter++] == 'r')
        {
            int reg_num = atoi(&(line->line[counter]));
            
            if (reg_num >= 1 && reg_num <= 31)
                *regist1 = reg_num;
            else 
                return ERROR_READ;
        }
        else if (line->line[counter] == 'p' && line->line[counter + 1] == 'c' && isalpha(line->line[counter + 1]))
            *regist1 = 0;
        else
            return ERROR_READ;

        while (isalpha(line->line[counter]) || isdigit(line->line[counter]))
            counter++;
    }

    while (line->line[counter] == ' ' || line->line[counter] == '\t')
        counter++;

    if (line->line[counter++] != ',' && counter < line->length)
        return ERROR_READ;

    while (line->line[counter] == ' ' || line->line[counter] == '\t')
        counter++;

    if (isdigit(line->line[counter]) || (line->line[counter] == '-' && isdigit(line->line[counter + 1])))
    {
        *number = atoi(&(line->line[counter]));

        return SEC_ARGUMENT_CMD;
    }

    if (isalpha(line->line[counter]))
    {

        if (line->line[counter++] == 'r')
        {
            int reg_num = atoi(&(line->line[counter]));

            if (reg_num >= 1 && reg_num <= 31)
                *regist2 = reg_num;
            else
                return ERROR_READ;
        }
        else if (line->line[counter] == 'p' && line->line[counter + 1] == 'c' && isalpha(line->line[counter + 1]))
            *regist2 = 0;
        else
            return ERROR_READ;

        while (isalpha(line->line[counter]) || isdigit(line->line[counter]))
            counter++;
    }

    while (line->line[counter] == ' ' || line->line[counter] == '\t')
        counter++;

    if (counter >= line->length)
        return TWO_REG;

    if (line->line[counter++] != ',' && counter < line->length)
        return ERROR_READ;

    while (line->line[counter] == ' ' || line->line[counter] == '\t')
        counter++;

    if (isalpha(line->line[counter]))
    {
        if (line->line[counter++] == 'r')
        {
            int reg_num = atoi(&(line->line[counter]));

            if (reg_num >= 1 && reg_num <= 31)
                *regist3 = reg_num;
            else
                return ERROR_READ;
        }
        else if (line->line[counter] == 'p' && line->line[counter + 1] == 'c' && isalpha(line->line[counter + 1]))
            *regist3 = 0;
        else
            return ERROR_READ;

        return THREE_REG;
    }

    return NO_ARGUMENT_CMD;
}

void process_no_argument_cmd_line(char* asm_buffer, int* bytes_buffer, char* command, int command_number, FILE* file_listing)
{
    assert(asm_buffer);
    assert(bytes_buffer);
    assert(command);
    assert(file_listing);

    char code_command = asm_data[command_number];

    asm_buffer[*bytes_buffer] = code_command;
    *bytes_buffer += sizeof(char);

    int alignment_var = fprintf(file_listing, "%s", command);

    fprintf(file_listing, "%*.c", FILE_LISTING_INDENT - alignment_var + 1, ' ');

    fprintf(file_listing, "\"");
    hex_print((unsigned char*)&code_command, sizeof(char), file_listing);
    fprintf(file_listing, "\"\n");
}

void process_argument_cmd_line(char* asm_buffer, int* bytes_buffer, char* command, int command_number, int number, FILE* file_listing)
{
    assert(asm_buffer);
    assert(bytes_buffer);
    assert(command);
    assert(file_listing);

    int alignment_var = 0;

    asm_buffer[*bytes_buffer] = asm_data[command_number];
    *bytes_buffer += sizeof(char);

    *((int*)(asm_buffer + *bytes_buffer)) = number;
    *bytes_buffer += sizeof(int);

    alignment_var = fprintf(file_listing, "%s %d", command, number);

    fprintf(file_listing, "%*.c", FILE_LISTING_INDENT - alignment_var + 1, ' ');

    fprintf(file_listing, "\"");
    hex_print((unsigned char*)&asm_data[command_number], sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&number, sizeof(int), file_listing);
    fprintf(file_listing, "\"\n");
}

void process_2_regs_cmd_line(char* asm_buffer, int* bytes_buffer, char* command, int command_number, char regist1, char regist2, FILE* file_listing)
{
    assert(asm_buffer);
    assert(bytes_buffer);
    assert(command);
    assert(file_listing);

    int alignment_var = 0;

    asm_buffer[*bytes_buffer] = asm_data[command_number];
    *bytes_buffer += sizeof(char);

    *((char*)(asm_buffer + *bytes_buffer)) = regist1;
    *bytes_buffer += sizeof(char);
    *((char*)(asm_buffer + *bytes_buffer)) = regist2;
    *bytes_buffer += sizeof(char);

    if (regist1 == 0 && regist2 == 0)
        alignment_var = fprintf(file_listing, "%s pc, pc", command);

    if (regist1 != 0 && regist2 == 0)
        alignment_var = fprintf(file_listing, "%s r%d, pc", command, regist1);

    if (regist1 == 0 && regist2 != 0)
        alignment_var = fprintf(file_listing, "%s pc, r%d", command, regist2);

    if (regist1 != 0 && regist2 != 0)
        alignment_var = fprintf(file_listing, "%s r%d, r%d", command, regist1, regist2);

    fprintf(file_listing, "%*.c", FILE_LISTING_INDENT - alignment_var + 1, ' ');

    fprintf(file_listing, "\"");
    hex_print((unsigned char*)&asm_data[command_number], sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&regist1, sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&regist2, sizeof(char), file_listing);

    fprintf(file_listing, "\"\n");
}

void process_reg_sec_cmd_line(char* asm_buffer, int* bytes_buffer, char* command, int command_number, char regist1, int number, FILE* file_listing)
{
    assert(asm_buffer);
    assert(bytes_buffer);
    assert(command);
    assert(file_listing);

    int alignment_var = 0;
    int code = asm_data[command_number] + 50;
    asm_buffer[*bytes_buffer] = code;
    *bytes_buffer += sizeof(char);

    *((char*)(asm_buffer + *bytes_buffer)) = regist1;
    *bytes_buffer += sizeof(char);
    *((int*)(asm_buffer + *bytes_buffer)) = number;
    *bytes_buffer += sizeof(int);

    if (regist1 == 0)
        alignment_var = fprintf(file_listing, "%s pc, %d", command, number);

    if (regist1 != 0)
        alignment_var = fprintf(file_listing, "%s r%d, %d", command, regist1, number);

    fprintf(file_listing, "%*.c", FILE_LISTING_INDENT - alignment_var + 1, ' ');

    fprintf(file_listing, "\"");
    hex_print((unsigned char*)&code, sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&regist1, sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&number, sizeof(int), file_listing);

    fprintf(file_listing, "\"\n");
}

void process_3_regs_cmd_line(char* asm_buffer, int* bytes_buffer, char* command, int command_number, char regist1, char regist2, char regist3, FILE* file_listing)
{
    assert(asm_buffer);
    assert(bytes_buffer);
    assert(command);
    assert(file_listing);

    int alignment_var = 0;

    asm_buffer[*bytes_buffer] = asm_data[command_number];
    *bytes_buffer += sizeof(char);

    *((char*)(asm_buffer + *bytes_buffer)) = regist1;
    *bytes_buffer += sizeof(char);
    *((char*)(asm_buffer + *bytes_buffer)) = regist2;
    *bytes_buffer += sizeof(char);
    *((char*)(asm_buffer + *bytes_buffer)) = regist3;
    *bytes_buffer += sizeof(char);

    if (regist1 != 0 && regist2 != 0)
        alignment_var = fprintf(file_listing, "%s r%d, r%d, r%d", command, regist1, regist2, regist3);

    fprintf(file_listing, "%*.c", FILE_LISTING_INDENT - alignment_var + 1, ' ');

    fprintf(file_listing, "\"");
    hex_print((unsigned char*)&asm_data[command_number], sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&regist1, sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&regist2, sizeof(char), file_listing);
    fprintf(file_listing, " ");
    hex_print((unsigned char*)&regist3, sizeof(char), file_listing);

    fprintf(file_listing, "\"\n");
}

int hash_text(const char* line)
{
    assert(line);

    int temp = 1;

    int length_of_line = strlen(line);

    for (int i = 1; i <= length_of_line; i++)
        temp += temp * i * i * line[i - 1];

    return temp;
}

int hash_search(int hash_command)
{
    for (int i = 0; i < DATA_SIZE; i++)
        if (hash_command == hash_data[i])
            return i;

    return ERROR_HASH;
}

void hex_print(unsigned char* hex, size_t size_hex, FILE* res)
{
    assert(hex);
    assert(res);

    for (int i = size_hex - 1; i >= 1; i--)
        fprintf(res, "%02x ", hex[i]);

    fprintf(res, "%02x", hex[0]);
}