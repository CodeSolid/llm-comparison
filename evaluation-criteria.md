* Does the delete.sh file get generated correctly?
* Are the filenames and checksums loaded into an associative array on at least one side, or are they processed as a list?
* Does the program check the input directories to make sure they exist before scanning either directory?  Does it do any other checks on the name?
* What happens if you pass in a file as one or both parameters?
* What happens if both directories are the same (should error and exit)?
* What happens if one directory is a subdirectory of the other?
* Was delete.sh generated as executable ("chmod u+x", for example")
* How long does generating delete.sh take?
* Are the temp files created in the expected ("$TMRDIR") location? 
* Are they deleted at the end of the run?
* Does the format of the temp files make sense?
* Does the process check to see if delete.sh is already created, and handle it gracefully?
* When is this check performed?
* What does "-h" do?
* What does passing no parameters do?
* How readable is the code to someone with good bash knowledge?
* How well documented is the code?
* Are there any instructions for using delete.sh included?