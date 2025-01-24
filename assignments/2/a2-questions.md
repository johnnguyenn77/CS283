## Assignment 2 Questions

#### Directions
Please answer the following questions and submit in your repo for the second assignment.  Please keep the answers as short and concise as possible.

1. In this assignment I asked you provide an implementation for the `get_student(...)` function because I think it improves the overall design of the database application.   After you implemented your solution do you agree that externalizing `get_student(...)` into it's own function is a good design strategy?  Briefly describe why or why not.

    > **ANSWER:** Yes, externalizing `get_student(...)` into its own function is a good design strategy. It promotes code reusability and modularity, making the code easier to maintain and understand. By isolating the logic for retrieving a student record, we can avoid code duplication and reduce the risk of errors. Additionally, it allows for easier testing and debugging of the `get_student(...)` function independently from the rest of the application.

2. Another interesting aspect of the `get_student(...)` function is how its function prototype requires the caller to provide the storage for the `student_t` structure:

    ```c
    int get_student(int fd, int id, student_t *s);
    ```

    Notice that the last parameter is a pointer to storage **provided by the caller** to be used by this function to populate information about the desired student that is queried from the database file. This is a common convention (called pass-by-reference) in the `C` programming language. 

    In other programming languages an approach like the one shown below would be more idiomatic for creating a function like `get_student()` (specifically the storage is provided by the `get_student(...)` function itself):

    ```c
    //Lookup student from the database
    // IF FOUND: return pointer to student data
    // IF NOT FOUND: return NULL
    student_t *get_student(int fd, int id){
        student_t student;
        bool student_found = false;
        
        //code that looks for the student and if
        //found populates the student structure
        //The found_student variable will be set
        //to true if the student is in the database
        //or false otherwise.

        if (student_found)
            return &student;
        else
            return NULL;
    }
    ```
    Can you think of any reason why the above implementation would be a **very bad idea** using the C programming language?  Specifically, address why the above code introduces a subtle bug that could be hard to identify at runtime?

    > **ANSWER:** The above implementation is a very bad idea in C because it returns a pointer to a local variable (`student`). When the function `get_student(...)` returns, the local variable `student` goes out of scope and its memory is deallocated. This means that the returned pointer will point to an invalid memory location, leading to undefined behavior when the caller tries to access the student data. This subtle bug can be hard to identify at runtime because the memory location might still contain the expected data for a short period, but it can be overwritten at any time, causing unpredictable results.

3. Another way the `get_student(...)` function could be implemented is as follows:

    ```c
    //Lookup student from the database
    // IF FOUND: return pointer to student data
    // IF NOT FOUND or memory allocation error: return NULL
    student_t *get_student(int fd, int id){
        student_t *pstudent;
        bool student_found = false;

        pstudent = malloc(sizeof(student_t));
        if (pstudent == NULL)
            return NULL;

        //code that looks for the student and if
        //found populates the student structure
        //The found_student variable will be set
        //to true if the student is in the database
        //or false otherwise.

        if (student_found){
            return pstudent;
        }
        else {
            free(pstudent);
            return NULL;
        }
    }
    ```
    In this implementation the storage for the student record is allocated on the heap using `malloc()` and passed back to the caller when the function returns. What do you think about this alternative implementation of `get_student(...)`?  Address in your answer why it work work, but also think about any potential problems it could cause.

    > **ANSWER:** This alternative implementation of `get_student(...)` works because it allocates memory on the heap for the student record, which persists after the function returns. This avoids the issue of returning a pointer to a local variable. However, this approach introduces potential problems such as memory leaks if the caller forgets to free the allocated memory. Additionally, frequent allocations and deallocations can lead to memory fragmentation, which can degrade performance over time. Proper memory management is crucial to avoid these issues.


4. Lets take a look at how storage is managed for our simple database. Recall that all student records are stored on disk using the layout of the `student_t` structure (which has a size of 64 bytes).  Lets start with a fresh database by deleting the `student.db` file using the command `rm ./student.db`.  Now that we have an empty database lets add a few students and see what is happening under the covers.  Consider the following sequence of commands:

    ```bash
    > ./sdbsc -a 1 john doe 345
    > ls -l ./student.db
        -rw-r----- 1 bsm23 bsm23 128 Jan 17 10:01 ./student.db
    > du -h ./student.db
        4.0K    ./student.db
    > ./sdbsc -a 3 jane doe 390
    > ls -l ./student.db
        -rw-r----- 1 bsm23 bsm23 256 Jan 17 10:02 ./student.db
    > du -h ./student.db
        4.0K    ./student.db
    > ./sdbsc -a 63 jim doe 285
    > du -h ./student.db
        4.0K    ./student.db
    > ./sdbsc -a 64 janet doe 310
    > du -h ./student.db
        8.0K    ./student.db
    > ls -l ./student.db
        -rw-r----- 1 bsm23 bsm23 4160 Jan 17 10:03 ./student.db
    ```

    For this question I am asking you to perform some online research to investigate why there is a difference between the size of the file reported by the `ls` command and the actual storage used on the disk reported by the `du` command.  Understanding why this happens by design is important since all good systems programmers need to understand things like how linux creates sparse files, and how linux physically stores data on disk using fixed block sizes.  Some good google searches to get you started: _"lseek syscall holes and sparse files"_, and _"linux file system blocks"_.  After you do some research please answer the following:

    - Please explain why the file size reported by the `ls` command was 128 bytes after adding student with ID=1, 256 after adding student with ID=3, and 4160 after adding the student with ID=64?

        > **ANSWER:** The file size reported by the `ls` command reflects the logical size of the file, which includes all the data written to it, including any gaps or holes created by seeking to a position beyond the current end of the file and writing data. When a student with ID=1 is added, the file size is 128 bytes because the `student_t` structure is 64 bytes, and the database might include some metadata or padding. Adding a student with ID=3 increases the file size to 256 bytes, as it likely includes space for the students with IDs 1, 2, and 3. When a student with ID=64 is added, the file size jumps to 4160 bytes because it includes space for all students from ID=1 to ID=64, with each student record taking up 64 bytes.

    -   Why did the total storage used on the disk remain unchanged when we added the student with ID=1, ID=3, and ID=63, but increased from 4K to 8K when we added the student with ID=64?

        > **ANSWER:** The total storage used on the disk remained unchanged when adding students with ID=1, ID=3, and ID=63 because the file system allocates storage in fixed-size blocks (typically 4K). The initial allocation of 4K was sufficient to store the data for these students, even though the logical file size increased. When the student with ID=64 was added, the logical file size exceeded the initial 4K block, requiring the allocation of an additional 4K block, thus increasing the total storage used on the disk to 8K.

    - Now lets add one more student with a large student ID number  and see what happens:

        ```bash
        > ./sdbsc -a 99999 big dude 205 
        > ls -l ./student.db
        -rw-r----- 1 bsm23 bsm23 6400000 Jan 17 10:28 ./student.db
        > du -h ./student.db
        12K     ./student.db
        ```
        We see from above adding a student with a very large student ID (ID=99999) increased the file size to 6400000 as shown by `ls` but the raw storage only increased to 12K as reported by `du`.  Can provide some insight into why this happened?

        > **ANSWER:** Adding a student with a very large student ID (ID=99999) caused the file size to increase to 6400000 bytes as shown by `ls` because the file now logically includes space for all student records from ID=1 to ID=99999. However, the actual storage used on disk only increased to 12K as reported by `du` because the file system uses sparse file techniques. Sparse files allow the file system to allocate disk blocks only for the data that is actually written, and not for the gaps or holes created by seeking to a position beyond the current end of the file. This means that although the logical file size is large, the physical storage used is much smaller, as only the blocks containing actual data are allocated on disk.
