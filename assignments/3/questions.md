1. In this assignment I suggested you use `fgets()` to get user input in the main while loop. Why is `fgets()` a good choice for this application?

    > **Answer**: `fgets()` is a good choice because it reads input line by line, stopping at a newline or EOF, which is ideal for processing commands in a shell. It also handles buffer overflow by limiting the number of characters read, ensuring safe input handling.

2. You needed to use `malloc()` to allocte memory for `cmd_buff` in `dsh_cli.c`. Can you explain why you needed to do that, instead of allocating a fixed-size array?

    > **Answer**: Using `malloc()` allows dynamic memory allocation, which can be adjusted based on the input size. This is more flexible than a fixed-size array, which might be too small for some inputs or waste memory if too large.

3. In `dshlib.c`, the function `build_cmd_list(`)` must trim leading and trailing spaces from each command before storing it. Why is this necessary? If we didn't trim spaces, what kind of issues might arise when executing commands in our shell?

    > **Answer**: Trimming spaces is necessary to avoid issues with command parsing and execution. Leading or trailing spaces can cause commands to be misinterpreted or fail to execute, as the shell might treat them as part of the command or arguments.

4. For this question you need to do some research on STDIN, STDOUT, and STDERR in Linux. We've learned this week that shells are "robust brokers of input and output". Google _"linux shell stdin stdout stderr explained"_ to get started.

- One topic you should have found information on is "redirection". Please provide at least 3 redirection examples that we should implement in our custom shell, and explain what challenges we might have implementing them.

    > **Answer**:
    > 1. `command > file`: Redirects STDOUT to a file. Challenge: Handling file creation and permissions.
    > 2. `command < file`: Redirects STDIN from a file. Challenge: Ensuring the file exists and is readable.
    > 3. `command 2> file`: Redirects STDERR to a file. Challenge: Differentiating between STDOUT and STDERR streams.

- You should have also learned about "pipes". Redirection and piping both involve controlling input and output in the shell, but they serve different purposes. Explain the key differences between redirection and piping.

    > **Answer**: Redirection changes the source or destination of STDIN, STDOUT, or STDERR to/from files, while piping connects the output of one command directly to the input of another, allowing for command chaining.

- STDERR is often used for error messages, while STDOUT is for regular output. Why is it important to keep these separate in a shell?

    > **Answer**: Keeping STDERR and STDOUT separate allows users to distinguish between regular output and error messages, making it easier to debug and handle errors appropriately.

- How should our custom shell handle errors from commands that fail? Consider cases where a command outputs both STDOUT and STDERR. Should we provide a way to merge them, and if so, how?

    > **Answer**: Our custom shell should capture and display STDERR separately from STDOUT. However, we can provide an option to merge them using `2>&1` syntax, which redirects STDERR to STDOUT, allowing users to see all output in a single stream if desired.
