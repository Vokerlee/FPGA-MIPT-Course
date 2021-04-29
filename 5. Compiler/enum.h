#pragma once

enum commands 
{
#define DEF_CMD(name, num, hash) \
        name = num,

#include "commands.h"

#undef DEF_CMD
};