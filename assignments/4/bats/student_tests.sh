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

@test "cd to a valid directory" {
    run ./dsh <<EOF
cd /tmp
pwd
EOF

    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '[:space:]')

    # Expected output with all whitespace removed for easier matching
    expected_output="/tmpdsh2>dsh2>dsh2>cmdloopreturned0"

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
    expected_output="cdfailed:Nosuchfileordirectorydsh2>dsh2>cmdloopreturned0"

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
    expected_output="$(pwd)dsh2>dsh2>dsh2>cmdloopreturned0"

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
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')

    # Expected output with all whitespace removed for easier matching
    expected_output="hello worlddsh2> dsh2> cmd loop returned 0"

    # These echo commands will help with debugging and will only print
    #if the test fails
    echo "Captured stdout:" 
    echo "Output: $output"
    echo "Exit Status: $status"
    echo "${stripped_output} -> ${expected_output}"

    # Check exact match
    [ "$stripped_output" = "$expected_output" ]
}

@test "handle command not found" {
    run ./dsh <<EOF
nonexistentcommand
rc
EOF
    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="Command not found in PATHdsh2> dsh2> dsh2> 2dsh2> cmd loop returned 0"

    # Assertions
    [ "$status" -eq 0 ]
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
    expected_output="cdfailed:Permissiondenied/tmpdsh2>dsh2>dsh2>cmdloopreturned0"

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

@test "handle successful command" {
    run ./dsh <<EOF
uname -a
rc
EOF
    # Strip all whitespace (spaces, tabs, newlines) from the output
    stripped_output=$(echo "$output" | tr -d '\t\n\r\f\v')
    expected_output="$(uname -a)dsh2> dsh2> 0dsh2> cmd loop returned 0"
    # Assertions
    [ "$status" -eq 0 ]
    [ "$stripped_output" = "$expected_output" ]
}
