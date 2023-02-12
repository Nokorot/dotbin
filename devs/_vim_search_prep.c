//
// Compile: 
//  $ gcc -o ~/.bin/_vim_search_prop _vim_search_prop.c -ljansson
// 



#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

#include <jansson.h>

// Inplace rtrim
char *rtrim(char *str, bool ignore_escape_sequenses) 
{
    char *ch = str, *last_non_space = str-1;
    ch = str;
    while (*ch) {
        if (isspace(*ch))
            ++ch;
        else last_non_space = ch++;
    }

    *(last_non_space+1) = '\0';

    return str;
}

void split(char *search_key, json_t *jout, char *line)
{
    json_t *jentry = json_object();
    json_auto_t *jfilename = json_string(line);
    json_object_set(jentry, "filename", jfilename);

    int fn_len = strlen(line),  line_num = 0;
    char *c = line + fn_len+1;
    while (*c != ':')
        line_num = line_num*10 + *(c++)-'0';
   
    json_auto_t *jline_num = json_integer(line_num);
    json_object_set(jentry, "line_num", jline_num);

    // Skip the colon folowing the line_number
    ++c;
    // ltrim
    while (isspace(*c)) ++c;

    rtrim(c, true);
    
    // TODO: It should be an option to stip all the text before the key.
    //  at lest in the case of TODO.

    json_auto_t *jtext = json_string(c);
    json_object_set(jentry, "text", jtext);

    // This conflicst with regex, so it's desabled
    // char *c2 = c;

    // int key_len = strlen(search_key);
    // while(strncmp(c2, search_key, key_len)) c2++;
    // c2 += key_len;
    // int column = c2 - line;
    // 
    // json_auto_t *jcolumn = json_integer(column);
    // json_object_set(jentry, "column", jcolumn);


    // Generate decriptor, this is what will be shown by dmenu
    int col_a = 10;
    int col_b = 50;
    int spacing = 2;


    int mn = col_a > fn_len ? fn_len : col_a; 

    char key[100], *key_c = key + mn;
    strncpy(key, line + fn_len - mn, mn);
    *(key_c++) = ':';

    for (int i=mn; i < col_a + spacing; ++i)
        *(key_c++) = ' ';

    strncpy(key_c, c, col_b);

    json_object_set(jout, key, jentry);
}

int main(int argc, char **argv) {
    json_t *jout = json_object();

    if (argc < 2) {
        fprintf(stderr, "ERROR: Not enough arguments!\n");
        exit(1);
    }

    char *line = NULL;
    size_t len = 0;
    ssize_t nread;

    while ((nread = getline(&line, &len, stdin)) != -1) {
        // printf("Retrieved line of length %zu:\n", nread);
        split(argv[1], jout, line);
    }

    free(line);
    
    char *out = json_dumps(jout, 0);
    
    printf("%s\n", out);
    return 0;
}
