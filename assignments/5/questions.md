1. Your shell forks multiple child processes when executing piped commands. How does your implementation ensure that all child processes complete before the shell continues accepting user input? What would happen if you forgot to call waitpid() on all child processes?

My implementation ensures that all child processes complete before the shell continues accepting user input by calling `waitpid()` on each child process. This is done in a loop after all the child processes have been forked. If I forgot to call `waitpid()` on all child processes, the shell would not wait for the child processes to complete, leading to potential race conditions and orphaned processes.

2. The dup2() function is used to redirect input and output file descriptors. Explain why it is necessary to close unused pipe ends after calling dup2(). What could go wrong if you leave pipes open?

It is necessary to close unused pipe ends after calling `dup2()` to prevent descriptor leaks. If pipes are left open, it can lead to resource exhaustion as the number of available file descriptors is limited. Additionally, leaving pipes open can cause unintended behavior, such as blocking reads or writes, because the pipe remains open in multiple processes.

3. Your shell recognizes built-in commands (cd, exit, dragon). Unlike external commands, built-in commands do not require execvp(). Why is cd implemented as a built-in rather than an external command? What challenges would arise if cd were implemented as an external process?

The `cd` command is implemented as a built-in command because it needs to change the current working directory of the shell process itself. If `cd` were implemented as an external process, it would only change the working directory of the child process, not the shell process. This would make it ineffective for changing the shell's working directory.

4. Currently, your shell supports a fixed number of piped commands (CMD_MAX). How would you modify your implementation to allow an arbitrary number of piped commands while still handling memory allocation efficiently? What trade-offs would you need to consider?

To allow an arbitrary number of piped commands, I would use dynamic memory allocation to create the command list and pipe file descriptors. This can be done using `malloc()` and `realloc()` to resize the arrays as needed. The trade-offs to consider include increased complexity in managing memory and ensuring that memory is properly allocated and freed to avoid leaks. Additionally, handling a large number of commands may impact performance and resource usage.
