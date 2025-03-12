#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#define BUFFER_SZ 50

//prototypes
void usage(char *);
void print_buff(char *, int);
int  setup_buff(char *, char *, int);

//prototypes for functions to handle required functionality
int  count_words(char *, int, int);
//add additional prototypes here


int setup_buff(char *buff, char *user_str, int len){
    //TODO: #4:  Implement the setup buff as per the directions
    int i = 0, j = 0;
    int consecutive_space = 0;

    // Check if user_str is too large
    while (*(user_str + i) != '\0') {
        if (i >= len) {
            return -1; // user_str is too large
        }
        i++;
    }

    i = 0;
    while (*(user_str + i) != '\0' && j < len) {
        if (*(user_str + i) == ' ' || *(user_str + i) == '\t') {
            if (!consecutive_space) {
                *(buff + j) = ' ';
                j++;
                consecutive_space = 1;
            }
        } else {
            *(buff + j) = *(user_str + i);
            j++;
            consecutive_space = 0;
        }
        i++;
    }

    // Fill the remainder of the buffer with '.'
    while (j < len) {
        *(buff + j) = '.';
        j++;
    }

    return i; // return the length of the user supplied string
    // return 0; //for now just so the code compiles.
}

void print_buff(char *buff, int len){
    printf("Buffer:  ");
    for (int i=0; i<len; i++){
        putchar(*(buff+i));
    }
    putchar('\n');
}

void usage(char *exename){
    printf("usage: %s [-h|c|r|w|x] \"string\" [other args]\n", exename);

}

int count_words(char *buff, int len, int str_len) {
    int word_count = 0;
    int in_word = 0;

    for (int i = 0; i < str_len; i++) {
        if (*(buff + i) != ' ' && *(buff + i) != '.') {
            if (!in_word) {
                word_count++;
                in_word = 1;
            }
        } else {
            in_word = 0;
        }
    }

    return word_count;
}

//ADD OTHER HELPER FUNCTIONS HERE FOR OTHER REQUIRED PROGRAM OPTIONS

int main(int argc, char *argv[]){

    char *buff;             //placehoder for the internal buffer
    char *input_string;     //holds the string provided by the user on cmd line
    char opt;               //used to capture user option from cmd line
    int  rc;                //used for return codes
    int  user_str_len;      //length of user supplied string

    //TODO:  #1. WHY IS THIS SAFE, aka what if argv[1] does not exist?
    // This check ensures that there are at least two arguments provided (argc < 2).
    // If argv[1] does not exist, the program will print the usage message and exit.
    // Additionally, it checks if the first character of argv[1] is a '-' to ensure
    // that the user has provided an option flag. If not, it will also print the usage
    // message and exit.
    if ((argc < 2) || (*argv[1] != '-')){
        usage(argv[0]);
        exit(1);
    }

    opt = (char)*(argv[1]+1);   //get the option flag

    //handle the help flag and then exit normally
    if (opt == 'h'){
        usage(argv[0]);
        exit(0);
        }

        //WE NOW WILL HANDLE THE REQUIRED OPERATIONS

        //TODO:  #2 Document the purpose of the if statement below
        // This check ensures that there are at least three arguments provided (argc < 3).
        // If there are fewer than three arguments, the program will print the usage message and exit.
        // This is necessary because the program expects an option flag (argv[1]) and a string (argv[2]).
        if (argc < 3){
        usage(argv[0]);
        exit(1);
        }

    input_string = argv[2]; //capture the user input string

    //TODO:  #3 Allocate space for the buffer using malloc and
    //          handle error if malloc fails by exiting with a 
    //          return code of 99
    buff = (char *)malloc(BUFFER_SZ * sizeof(char));
    if (buff == NULL) {
        printf("Memory allocation failed\n");
        exit(99);
    }


    user_str_len = setup_buff(buff, input_string, BUFFER_SZ);     //see todos
    if (user_str_len < 0){
        printf("Error setting up buffer, error = %d", user_str_len);
        exit(2);
    }

    switch (opt){
        case 'c':
            rc = count_words(buff, BUFFER_SZ, user_str_len);  //you need to implement
            if (rc < 0){
                printf("Error counting words, rc = %d", rc);
                exit(2);
            }
            printf("Word Count: %d\n", rc);
            break;

        case 'r': {
            // Reverse the string
            for (int i = 0; i < user_str_len / 2; i++) {
                char temp = *(buff + i);
                *(buff + i) = *(buff + user_str_len - 1 - i);
                *(buff + user_str_len - 1 - i) = temp;
            }
            printf("Reversed String: ");
            for (int i = 0; i < user_str_len; i++) {
                putchar(*(buff + i));
            }
            putchar('\n');
            break;
        }
        case 'x': {
            // Ensure there are enough arguments for the replace operation
            if (argc < 5) {
            printf("Error: Not enough arguments for replace operation\n");
            exit(1);
            }

            char *search_str = argv[3];
            char *replace_str = argv[4];
            int search_len = 0;
            int replace_len = 0;

            // Calculate lengths of search_str and replace_str
            while (*(search_str + search_len) != '\0') search_len++;
            while (*(replace_str + replace_len) != '\0') replace_len++;

            // Find the search_str in buff
            char *pos = buff;
            while (pos < buff + user_str_len) {
            char *p = pos;
            char *q = search_str;
            while (*q != '\0' && *p == *q) {
                p++;
                q++;
            }
            if (*q == '\0') {
                break; // Found the search_str
            }
            pos++;
            }

            if (pos >= buff + user_str_len) {
            printf("Error: Search string not found\n");
            exit(3);
            }

            // Check if replacement will overflow the buffer
            if (user_str_len - search_len + replace_len > BUFFER_SZ) {
            printf("Error: Replacement would overflow buffer\n");
            exit(3);
            }

            // Perform the replacement
            char *end = buff + user_str_len;
            if (replace_len != search_len) {
            // Shift the buffer content if necessary
            if (replace_len < search_len) {
                memmove(pos + replace_len, pos + search_len, end - (pos + search_len));
            } else {
                memmove(pos + replace_len, pos + search_len, end - pos);
            }
            }
            memcpy(pos, replace_str, replace_len);

            // Update user_str_len
            user_str_len = user_str_len - search_len + replace_len;

            printf("Modified String: ");
            for (int i = 0; i < user_str_len; i++) {
            putchar(*(buff + i));
            }
            putchar('\n');
            break;
        }

        case 'w': {
            // Print words and their lengths
            printf("Word Print\n----------\n");
            int word_start = 0;
            int word_len = 0;
            int word_count = 1;
            for (int i = 0; i <= user_str_len; i++) {
                if (*(buff + i) != ' ' && *(buff + i) != '.' && *(buff + i) != '\0') {
                    if (word_len == 0) {
                        word_start = i;
                    }
                    word_len++;
                } else {
                    if (word_len > 0) {
                        printf("%d. ", word_count);
                        for (int j = word_start; j < word_start + word_len; j++) {
                            putchar(*(buff + j));
                        }
                        printf(" (%d)\n", word_len);
                        word_count++;
                        word_len = 0;
                    }
                }
            }
            break;
        }

        //TODO:  #5 Implement the other cases for 'r' and 'w' by extending
        //       the case statement options
        default:
            usage(argv[0]);
            exit(1);
    }

    //TODO:  #6 Dont forget to free your buffer before exiting
    print_buff(buff, BUFFER_SZ);
    free(buff);
    exit(0);
}

//TODO:  #7  Notice all of the helper functions provided in the 
//          starter take both the buffer as well as the length.  Why
//          do you think providing both the pointer and the length
//          is a good practice, after all we know from main() that 
//          the buff variable will have exactly 50 bytes?
//  
//          It helps prevent buffer overflows by ensuring that the function knows the exact size of the buffer it is working with.
//          It allows the function to handle buffers of different sizes without relying on hardcoded values.
