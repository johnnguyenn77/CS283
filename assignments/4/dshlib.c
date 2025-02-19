#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include "dshlib.h"

// Forward declarations of the missing functions
int build_cmd_buff(char *cmd_line, cmd_buff_t *cmd_buff);
Built_In_Cmds match_command(const char *cmd);

int last_rc = 0;

/*
 * Implement your exec_local_cmd_loop function by building a loop that prompts the 
 * user for input.  Use the SH_PROMPT constant from dshlib.h and then
 *        printf("%s", SH_PROMPT);
 *        if (fgets(cmd_buff, ARG_MAX, stdin) == NULL){
 *           printf("\n");
 *           break;
 *        }
 *        //remove the trailing \n from cmd_buff
 *        cmd_buff[strcspn(cmd_buff,"\n")] = '\0';
 * 
 *        //IMPLEMENT THE REST OF THE REQUIREMENTS
 *      }
 * 
 *   Also, use the constants in the dshlib.h in this code.  
 *      SH_CMD_MAX              maximum buffer size for user input
 *      EXIT_CMD                constant that terminates the dsh program
 *      SH_PROMPT               the shell prompt
 *      OK                      the command was parsed properly
 *      WARN_NO_CMDS            the user command was empty
 *      ERR_TOO_MANY_COMMANDS   too many pipes used
 *      ERR_MEMORY              dynamic memory management failure
 * 
 *   errors returned
 *      OK                     No error
 *      ERR_MEMORY             Dynamic memory management failure
 *      WARN_NO_CMDS           No commands parsed
 *      ERR_TOO_MANY_COMMANDS  too many pipes used
 *   
 *   console messages
 *      CMD_WARN_NO_CMD        print on WARN_NO_CMDS
 *      CMD_ERR_PIPE_LIMIT     print on ERR_TOO_MANY_COMMANDS
 *      CMD_ERR_EXECUTE        print on execution failure of external command
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 1+)
 *      malloc(), free(), strlen(), fgets(), strcspn(), printf()
 * 
 *  Standard Library Functions You Might Want To Consider Using (assignment 2+)
 *      fork(), execvp(), exit(), chdir()
 */
int exec_local_cmd_loop()
{
    char cmd_line[SH_CMD_MAX];
    cmd_buff_t cmd_buff;
    int rc;

    while (1) {
        printf("%s", SH_PROMPT);
        if (fgets(cmd_line, SH_CMD_MAX, stdin) == NULL) {
            printf("\n");
            break;
        }
        cmd_line[strcspn(cmd_line, "\n")] = '\0';

        if (strlen(cmd_line) == 0) {
            printf(CMD_WARN_NO_CMD);
            continue;
        }

        rc = build_cmd_buff(cmd_line, &cmd_buff);
        if (rc != OK) {
            printf("Error: %d\n", rc);
            continue;
        }

        Built_In_Cmds cmd_type = match_command(cmd_buff.argv[0]);
        if (cmd_type == BI_CMD_EXIT) {
            break;
        } else if (cmd_type == BI_CMD_CD) {
            if (cmd_buff.argc == 2) {
                if (chdir(cmd_buff.argv[1]) != 0) {
                    perror("chdir");
                }
            }
        } else if (cmd_type == BI_RC) {
            printf("%d\n", rc);
        } else {
            pid_t pid = fork();
            if (pid == 0) {
                execvp(cmd_buff.argv[0], cmd_buff.argv);
                perror("execvp"); // Print error message
                exit(1); // Exit child process with error code
            } else if (pid > 0) {
                int status;
                waitpid(pid, &status, 0);
                if (WIFEXITED(status)) {
                    rc = WEXITSTATUS(status);
                }
            } else {
                perror("fork");
            }
        }
    }

    return OK;
}

int build_cmd_buff(char *cmd_line, cmd_buff_t *cmd_buff) {
    int argc = 0;
    bool in_quotes = false;
    char *current_arg = NULL;
    size_t current_arg_len = 0;

    cmd_buff->_cmd_buffer = strdup(cmd_line);
    if (!cmd_buff->_cmd_buffer) {
        return ERR_MEMORY;
    }

    char *ptr = cmd_buff->_cmd_buffer;
    while (*ptr) {
        if (*ptr == '"') {
            in_quotes = !in_quotes;
            if (!in_quotes) {
                cmd_buff->argv[argc++] = current_arg;
                current_arg = NULL;
                current_arg_len = 0;
            }
        } else if (isspace(*ptr) && !in_quotes) {
            if (current_arg) {
                cmd_buff->argv[argc++] = current_arg;
                current_arg = NULL;
                current_arg_len = 0;
            }
        } else {
            if (!current_arg) {
                current_arg = malloc(1);
                current_arg[0] = '\0';
                current_arg_len = 0;
            }
            current_arg = realloc(current_arg, current_arg_len + 2);
            current_arg[current_arg_len++] = *ptr;
            current_arg[current_arg_len] = '\0';
        }
        ptr++;
    }
    if (current_arg) {
        cmd_buff->argv[argc++] = current_arg;
    }
    cmd_buff->argv[argc] = NULL;
    cmd_buff->argc = argc;

    return OK;
}

Built_In_Cmds match_command(const char *cmd) {
    if (strcmp(cmd, EXIT_CMD) == 0) {
        return BI_CMD_EXIT;
    } else if (strcmp(cmd, "cd") == 0) {
        return BI_CMD_CD;
    } else if (strcmp(cmd, "rc") == 0) {
        return BI_RC;
    }
    return BI_NOT_BI;
}
