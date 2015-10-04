
The testing.c++ is a first attempt to automate the testing and fuzzing of the atm/bank.

To compile:
c++ testing.c++ -o prog_name
// in this case it can run by $ ./prog_name file_name

the program will take the command from a file (file_name) and call atm. It assumes that each line has a command for the atm (e.g., -s bank.auth -c bob.card -a bob -n 1000.0).
