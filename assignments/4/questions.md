1. Can you think of why we use `fork/execvp` instead of just calling `execvp` directly? What value do you think the `fork` provides?

    > **Answer**: We use `fork/execvp` instead of just calling `execvp` directly because `fork` creates a new child process that is a copy of the parent process. This allows the parent process to continue running and manage the child process. The `fork` provides the ability to run multiple processes concurrently and manage their execution, which is essential for a shell to handle multiple commands and processes.

2. What happens if the fork() system call fails? How does your implementation handle this scenario?

    > **Answer**: If the `fork()` system call fails, it returns -1. In the provided implementation, this scenario is handled by checking the return value of `fork()`. If it is less than 0, an error message is printed using `perror("fork")`.

3. How does execvp() find the command to execute? What system environment variable plays a role in this process?

    > **Answer**: `execvp()` finds the command to execute by searching through the directories listed in the `PATH` environment variable. The `PATH` variable contains a colon-separated list of directories that the system searches for executable files.

4. What is the purpose of calling wait() in the parent process after forking? What would happen if we didn’t call it?

    > **Answer**: The purpose of calling `wait()` in the parent process after forking is to wait for the child process to complete and to retrieve its exit status. If we didn’t call `wait()`, the child process would become a zombie process after it finishes, as its exit status would not be collected by the parent process. This can lead to resource leaks and an accumulation of zombie processes.

5. In the referenced demo code we used WEXITSTATUS(). What information does this provide, and why is it important?

    > **Answer**: `WEXITSTATUS()` extracts the exit status of the child process from the status value returned by `wait()`. This information is important because it allows the parent process to determine whether the child process terminated successfully or if there were any errors. It helps in handling errors and taking appropriate actions based on the exit status.

6. Describe how your implementation of build_cmd_buff() handles quoted arguments. Why is this necessary?

    > **Answer**: The implementation of `build_cmd_buff()` handles quoted arguments by toggling an `in_quotes` flag whenever a double-quote character is encountered. This ensures that spaces within quoted strings are preserved as part of the argument, rather than being treated as argument separators. This is necessary to correctly parse commands where arguments contain spaces, such as `echo "hello world"`.

7. What changes did you make to your parsing logic compared to the previous assignment? Were there any unexpected challenges in refactoring your old code?

    > **Answer**: The changes made to the parsing logic include handling quoted strings to preserve spaces within them and eliminating duplicate spaces outside of quoted strings. Additionally, the parsing logic was refactored to use a single `cmd_buff` structure instead of a command list. One unexpected challenge was ensuring that the quoted strings were correctly parsed and that memory management for dynamically allocated strings was handled properly.

8. For this question, you need to do some research on Linux signals. You can use [this google search](https://www.google.com/search?q=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&oq=Linux+signals+overview+site%3Aman7.org+OR+site%3Alinux.die.net+OR+site%3Atldp.org&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBBzc2MGowajeoAgCwAgA&sourceid=chrome&ie=UTF-8) to get started.

- What is the purpose of signals in a Linux system, and how do they differ from other forms of interprocess communication (IPC)?

    > **Answer**: Signals in a Linux system are used to notify processes of events or to request that they perform certain actions. They differ from other forms of interprocess communication (IPC) in that they are asynchronous and can be sent to a process at any time, interrupting its normal flow of execution. Other IPC mechanisms, such as pipes, message queues, and shared memory, involve explicit communication and synchronization between processes.

- Find and describe three commonly used signals (e.g., SIGKILL, SIGTERM, SIGINT). What are their typical use cases?

    > **Answer**:
  - `SIGKILL` (signal 9): This signal is used to forcefully terminate a process. It cannot be caught, blocked, or ignored by the process. Typical use case: killing a process that is unresponsive or stuck.
  - `SIGTERM` (signal 15): This signal requests a process to terminate gracefully. The process can catch this signal and perform cleanup operations before exiting. Typical use case: politely asking a process to terminate.
  - `SIGINT` (signal 2): This signal is sent when the user interrupts a process from the terminal, usually by pressing `Ctrl+C`. The process can catch this signal and handle it appropriately. Typical use case: allowing the user to interrupt and stop a running process.

- What happens when a process receives SIGSTOP? Can it be caught or ignored like SIGINT? Why or why not?

    > **Answer**: When a process receives `SIGSTOP`, it is immediately stopped (paused) by the operating system. Unlike `SIGINT`, `SIGSTOP` cannot be caught, blocked, or ignored by the process. This is because `SIGSTOP` is designed to allow the operating system or a user with appropriate permissions to unconditionally stop a process, regardless of the process's state or behavior.
