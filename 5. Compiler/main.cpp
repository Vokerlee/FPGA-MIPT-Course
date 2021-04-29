#include "compiler.h"

int main()
{
    FILE* source = fopen("code.txt", "r");
    FILE* res    = fopen("compiled_code.txt", "wb");

    assert(source);
    assert(res);

    text_t text = {};
    construct_text(&text);

    fill_text(source, &text);
    //print_text_lines(res, &text);

    compile(&text, res);

    destruct_text(&text);

    fclose(source);
    fclose(res);

    return 0;
}