#pragma once

const int FILE_LISTING_INDENT = 40;

const int ERROR_FORMAT = 1;
const int ERROR_UNKNOWN_CMD = 2;

const int ERROR_HASH = -1;
const int ERROR_READ = -2;

enum command_type
{
    NO_ARGUMENT_CMD  = 1,
    ARGUMENT_CMD     = 2,
    SEC_ARGUMENT_CMD = 3,
    THREE_REG        = 4,
    TWO_REG          = 5
};

const int DATA_SIZE = 11;

char asm_data[DATA_SIZE] =
{
    #define DEF_CMD(name, num, hash) \
        num,

    #include "commands.h"

    #undef DEF_CMD
};

int hash_data[DATA_SIZE] =
{
    #define DEF_CMD(name, num, hash) \
        hash,

    #include "commands.h"

    #undef DEF_CMD
};