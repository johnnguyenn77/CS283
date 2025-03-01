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
void handle_redirection(cmd_buff_t *cmd_buff);

int last_rc = 0;

int exec_local_cmd_loop()
{
    char cmd_line[SH_CMD_MAX];
    command_list_t cmd_list;
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

        rc = build_cmd_list(cmd_line, &cmd_list);
        if (rc != OK) {
            printf("Error: %d\n", rc);
            continue;
        }

        if (cmd_list.num == 1) {
            cmd_buff_t *cmd_buff = &cmd_list.commands[0];
            Built_In_Cmds cmd_type = match_command(cmd_buff->argv[0]);
            if (cmd_type == BI_CMD_EXIT) {
                printf("exiting...\n");
                break;
            } else if (cmd_type == BI_CMD_CD) {
                if (cmd_buff->argc == 2) {
                    if (chdir(cmd_buff->argv[1]) != 0) {
                        perror("cdfailed");
                    }
                }
            } else {
                pid_t pid = fork();
                if (pid == 0) {
                    handle_redirection(cmd_buff);
                    execvp(cmd_buff->argv[0], cmd_buff->argv);
                    perror("execvp");
                    exit(1);
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
        } else {
            rc = execute_pipeline(&cmd_list);
        }

        free_cmd_list(&cmd_list);
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

int build_cmd_list(char *cmd_line, command_list_t *clist) {
    char *token;
    int cmd_count = 0;

    clist->num = 0;

    token = strtok(cmd_line, PIPE_STRING);
    while (token != NULL) {
        if (cmd_count >= CMD_MAX) {
            return ERR_TOO_MANY_COMMANDS;
        }

        cmd_buff_t *cmd_buff = &clist->commands[cmd_count];
        int rc = build_cmd_buff(token, cmd_buff);
        if (rc != OK) {
            return rc;
        }

        cmd_count++;
        token = strtok(NULL, PIPE_STRING);
    }

    clist->num = cmd_count;
    return OK;
}

Built_In_Cmds match_command(const char *cmd) {
    if (strcmp(cmd, EXIT_CMD) == 0) {
        return BI_CMD_EXIT;
    } else if (strcmp(cmd, "cd") == 0) {
        return BI_CMD_CD;
    }

    return BI_NOT_BI;
}

int execute_pipeline(command_list_t *clist) {
    int pipefd[2 * (clist->num - 1)];
    pid_t pids[clist->num];

    for (int i = 0; i < clist->num - 1; i++) {
        if (pipe(pipefd + i * 2) < 0) {
            perror("pipe");
            return ERR_MEMORY;
        }
    }

    for (int i = 0; i < clist->num; i++) {
        pids[i] = fork();
        if (pids[i] == 0) {
            if (i > 0) {
                dup2(pipefd[(i - 1) * 2], STDIN_FILENO);
            }
            if (i < clist->num - 1) {
                dup2(pipefd[i * 2 + 1], STDOUT_FILENO);
            }
            for (int j = 0; j < 2 * (clist->num - 1); j++) {
                close(pipefd[j]);
            }
            handle_redirection(&clist->commands[i]);
            execvp(clist->commands[i].argv[0], clist->commands[i].argv);
            perror("execvp");
            exit(1);
        } else if (pids[i] < 0) {
            perror("fork");
            return ERR_MEMORY;
        }
    }

    for (int i = 0; i < 2 * (clist->num - 1); i++) {
        close(pipefd[i]);
    }

    for (int i = 0; i < clist->num; i++) {
        int status;
        waitpid(pids[i], &status, 0);
        if (WIFEXITED(status)) {
            last_rc = WEXITSTATUS(status);
        }
    }

    return OK;
}

void handle_redirection(cmd_buff_t *cmd_buff) {
    int input_fd = -1;
    int output_fd = -1;

    for (int i = 0; i < cmd_buff->argc; i++) {
        if (strcmp(cmd_buff->argv[i], ">") == 0) {
            output_fd = open(cmd_buff->argv[i + 1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (output_fd < 0) {
                perror("open");
                exit(1);
            }
            dup2(output_fd, STDOUT_FILENO);
            close(output_fd);
            cmd_buff->argv[i] = NULL;
        } else if (strcmp(cmd_buff->argv[i], ">>") == 0) {
            output_fd = open(cmd_buff->argv[i + 1], O_WRONLY | O_CREAT | O_APPEND, 0644);
            if (output_fd < 0) {
                perror("open");
                exit(1);
            }
            dup2(output_fd, STDOUT_FILENO);
            close(output_fd);
            cmd_buff->argv[i] = NULL;
        } else if (strcmp(cmd_buff->argv[i], "<") == 0) {
            input_fd = open(cmd_buff->argv[i + 1], O_RDONLY);
            if (input_fd < 0) {
                perror("open");
                exit(1);
            }
            dup2(input_fd, STDIN_FILENO);
            close(input_fd);
            cmd_buff->argv[i] = NULL;
        }
    }
}

int free_cmd_list(command_list_t *cmd_list) {
    for (int i = 0; i < cmd_list->num; i++) {
        free(cmd_list->commands[i]._cmd_buffer);
        for (int j = 0; j < cmd_list->commands[i].argc; j++) {
            free(cmd_list->commands[i].argv[j]);
        }
    }
    return OK;
}
