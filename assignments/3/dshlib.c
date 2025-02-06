#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "dshlib.h"

int build_cmd_list(char *cmd_line, command_list_t *clist)
{
    // Initialize command list
    clist->num = 0;
    memset(clist->commands, 0, sizeof(clist->commands));

    // Trim leading and trailing spaces
    while (isspace((unsigned char)*cmd_line)) cmd_line++;
    char *end = cmd_line + strlen(cmd_line) - 1;
    while (end > cmd_line && isspace((unsigned char)*end)) end--;
    end[1] = '\0';

    // Check if command line is empty
    if (strlen(cmd_line) == 0)
    {
        return WARN_NO_CMDS;
    }

    // Split command line by pipes
    char *cmd_start = cmd_line;
    while (cmd_start != NULL)
    {
        // Find the next pipe
        char *pipe_pos = strstr(cmd_start, PIPE_STRING);
        if (pipe_pos != NULL)
        {
            *pipe_pos = '\0';
        }

        // Trim leading and trailing spaces for each command
        while (isspace((unsigned char)*cmd_start)) cmd_start++;
        end = cmd_start + strlen(cmd_start) - 1;
        while (end > cmd_start && isspace((unsigned char)*end)) end--;
        end[1] = '\0';

        // Check for too many commands
        if (clist->num >= CMD_MAX)
        {
            return ERR_TOO_MANY_COMMANDS;
        }

        // Split command into executable and arguments
        char *exe = strtok(cmd_start, " ");
        char *args = strtok(NULL, "");

        // Check for command or arguments too big
        if (strlen(exe) >= EXE_MAX || (args != NULL && strlen(args) >= ARG_MAX))
        {
            return ERR_CMD_OR_ARGS_TOO_BIG;
        }

        // Populate command structure
        strcpy(clist->commands[clist->num].exe, exe);
        if (args != NULL)
        {
            strcpy(clist->commands[clist->num].args, args);
        }
        else
        {
            clist->commands[clist->num].args[0] = '\0';
        }
        clist->num++;

        // Move to the next command
        if (pipe_pos != NULL)
        {
            cmd_start = pipe_pos + strlen(PIPE_STRING);
        }
        else
        {
            cmd_start = NULL;
        }
    }

    return OK;
}
