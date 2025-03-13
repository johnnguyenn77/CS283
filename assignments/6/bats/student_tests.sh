#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

@test "Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "exit command" {
    run ./dsh <<EOF
exit
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "handle command not found" {
    run ./dsh <<EOF
nonexistentcommand
EOF
    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="Command not found in PATHlocal modedsh4> local modedsh4> dsh4> cmd loop returned 0"

    echo "Captured stdout:"
    echo "Output: $output"
    echo "${stripped_output} -> ${expected_output}"
    # Assertions
    [ "$status" -eq 0 ]
    [ "$stripped_output" = "$expected_output" ]
}

@test "cd to a valid directory" {
    run ./dsh <<EOF
cd /tmp
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="/tmplocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "cd to an invalid directory" {
    run ./dsh <<EOF
cd /nonexistent_directory
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="cdfailed:Nosuchfileordirectorylocalmodedsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "execute an external command" {
    run ./dsh <<EOF
uname -a
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "cd with no arguments does nothing" {
    run ./dsh <<EOF
cd
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="$(pwd)localmodedsh4>dsh4>dsh4>cmdloopreturned0"

    stripped_expected_output=$(echo "$expected_output" | tr -d '[:space:]')

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${stripped_expected_output}"

    # Check exact match
    [ "$stripped_output" = "$stripped_expected_output" ]
}

@test "execute multiple commands sequentially" {
    run ./dsh <<EOF
pwd
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "handle command with multiple arguments" {
    run ./dsh <<EOF
echo hello world
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="helloworldlocalmodedsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "handle no permission" {
    current_dir=$(pwd)

    cd /tmp
    mkdir -p no_perm_dir
    chmod 000 no_perm_dir

    run "${current_dir}/dsh" <<EOF
cd no_perm_dir
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    echo "$stripped_output"

    # Expected output with all whitespace removed for easier matching
    expected_output="cdfailed:Permissiondenied/tmplocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    chmod 777 no_perm_dir
    rmdir no_perm_dir
}

@test "execute piped commands" {
    run ./dsh <<EOF
ls | grep dshlib.c
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="dshlib.clocalmodedsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]
}

@test "output redirection" {
    run ./dsh <<EOF
echo "hello, class" > out.txt
cat out.txt
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello,classlocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    rm out.txt
}

@test "append redirection" {
    run ./dsh <<EOF
echo "hello, class" > out.txt
echo "this is line 2" >> out.txt
cat out.txt
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello,classthisisline2localmodedsh4>dsh4>dsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    rm out.txt
}

@test "execute command with input redirection" {
    echo "hello, class" > in.txt
    run ./dsh <<EOF
cat < in.txt
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello,classlocalmodedsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    rm in.txt
}

@test "execute command with both input and output redirection" {
    echo "hello, class" > in.txt
    run ./dsh <<EOF
cat < in.txt > out.txt
cat out.txt
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello,classlocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    rm in.txt out.txt
}

@test "execute command with input redirection and pipe" {
    echo "hello, class" > in.txt
    run ./dsh <<EOF
cat < in.txt | grep hello
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello,classlocalmodedsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    rm in.txt
}

@test "execute command with output redirection and pipe" {
    run ./dsh <<EOF
echo "hello, class" | grep hello > out.txt
cat out.txt
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello,classlocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    rm out.txt
}

@test "execute command with input and output redirection and pipe" {
    echo "hello, class" > in.txt
    run ./dsh <<EOF
cat < in.txt | grep hello > out.txt
cat out.txt
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello,classlocalmodedsh4>dsh4>dsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    echo "Server PID: $server_pid"
    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Assertions
    [ "$status" -eq 0 ]

    # Cleanup
    rm in.txt out.txt
}

# New tests for remote shell functionality

@test "start server and client, execute command remotely" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and execute a command
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
uname -a
EOF
    echo "Server PID: $server_pid"
    # Assertions
    [ "$status" -eq 0 ]

    # Stop the server
    kill $server_pid
}

@test "start server and client, execute built-in command remotely" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and execute a built-in command
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
cd /tmp
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="socketclientmode:addr:0.0.0.0:7899dsh4>dsh4>/tmpdsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"
    echo "Server PID: $server_pid"
    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Stop the server
    kill $server_pid
}

@test "start server and client, stop server remotely" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and stop the server
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
stop-server
EOF
    echo "Server PID: $server_pid"
    # Assertions
    [ "$status" -eq 0 ]

    # Ensure the server has stopped
    ! kill -0 $server_pid 2>/dev/null
}

@test "start server and client, execute multiple commands remotely" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and execute multiple commands
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
pwd
ls
EOF
    echo "Server PID: $server_pid"
    # Assertions
    [ "$status" -eq 0 ]

    # Stop the server
    kill $server_pid
}

@test "start server and client, handle command with multiple arguments remotely" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and execute a command with multiple arguments
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo hello world
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="socketclientmode:addr:0.0.0.0:7899dsh4>helloworlddsh4>cmdloopreturned0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "Server PID: $server_pid"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]

    # Stop the server
    kill $server_pid
}

# New tests for multi-threaded server functionality

@test "start multi-threaded server and multiple clients, execute commands concurrently" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 -x &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run multiple clients concurrently
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo client1
EOF
    client1_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo client2
EOF
    client2_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo client3
EOF
    client3_output="$output"
    echo "Server PID: $server_pid"

    # Assertions
    [ "$status" -eq 0 ]
    [[ "$client1_output" == *"client1"* ]]
    [[ "$client2_output" == *"client2"* ]]
    [[ "$client3_output" == *"client3"* ]]

    # Stop the server
    kill $server_pid
}

@test "start multi-threaded server and multiple clients, execute piped commands concurrently" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 -x &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run multiple clients concurrently
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
ls | grep dshlib.c
EOF
    client1_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
ls | grep rshlib.h
EOF
    client2_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
ls | grep dsh_cli.c
EOF
    client3_output="$output"
    echo "Server PID: $server_pid"

    # Assertions
    [ "$status" -eq 0 ]
    [[ "$client1_output" == *"dshlib.c"* ]]
    [[ "$client2_output" == *"rshlib.h"* ]]
    [[ "$client3_output" == *"dsh_cli.c"* ]]

    # Stop the server
    kill $server_pid
}

@test "start multi-threaded server and multiple clients, execute commands with redirection concurrently" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 -x &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run multiple clients concurrently
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo "client1 output" > client1.txt
cat client1.txt
EOF
    client1_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo "client2 output" > client2.txt
cat client2.txt
EOF
    client2_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo "client3 output" > client3.txt
cat client3.txt
EOF
    client3_output="$output"
    echo "Server PID: $server_pid"

    # Assertions
    [ "$status" -eq 0 ]
    [[ "$client1_output" == *"client1 output"* ]]
    [[ "$client2_output" == *"client2 output"* ]]
    [[ "$client3_output" == *"client3 output"* ]]

    # Cleanup
    rm client1.txt client2.txt client3.txt

    # Stop the server
    kill $server_pid
}

@test "start multi-threaded server and multiple clients, execute built-in commands concurrently" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 -x &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run multiple clients concurrently
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
cd /tmp
pwd
EOF
    client1_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
cd /var
pwd
EOF
    client2_output="$output"

    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
cd /home
pwd
EOF
    client3_output="$output"

    # Assertions
    [ "$status" -eq 0 ]
    [[ "$client1_output" == *"/tmp"* ]]
    [[ "$client2_output" == *"/var"* ]]
    [[ "$client3_output" == *"/home"* ]]

    # Stop the server
    kill $server_pid
}

@test "server mode: exit command" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and execute the exit command
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
exit
EOF

    # Assertions
    [ "$status" -eq 0 ]

    # Stop the server
    kill $server_pid
}

@test "server mode: cd command to an invalid directory" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and execute the cd command
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
cd /nonexistent_directory
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="socketclientmode:addr:0.0.0.0:7899dsh4>cdfailed:Nosuchfileordirectorydsh4>cmdloopreturned0"

    echo "${stripped_output} -> ${expected_output}"

    # Assertions
    [ "$stripped_output" = "$expected_output" ]

    # Stop the server
    kill $server_pid
}

@test "local mode: rc command after successful command" {
    run ./dsh <<EOF
echo hello
rc
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="hellolocalmodedsh4>dsh4>0dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "local mode: rc command after failed command" {
    run ./dsh <<EOF
cd /nonexistent
rc
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="cdfailed:Nosuchfileordirectorylocalmodedsh4>dsh4>1dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]
}

@test "server mode: rc command after successful command" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and test rc after successful command
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
echo hello
rc
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="socketclientmode:addr:0.0.0.0:7899dsh4>hellodsh4>0dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    # Stop the server
    kill $server_pid
}

@test "server mode: rc command after failed command" {
    # Start the server in the background
    ./dsh -s -i 0.0.0.0 -p 7899 &
    server_pid=$!

    # Give the server some time to start
    sleep 2

    # Run the client and test rc after failed command
    run ./dsh -c -i 0.0.0.0 -p 7899 <<EOF
cd /nonexistent
rc
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="socketclientmode:addr:0.0.0.0:7899dsh4>cdfailed:Nosuchfileordirectorydsh4>1dsh4>cmdloopreturned0"

    echo "Captured stdout:" 
    echo "Output: $output"
    echo "${stripped_output} -> ${expected_output}"

    [ "$stripped_output" = "$expected_output" ]

    # Stop the server
    kill $server_pid
}
