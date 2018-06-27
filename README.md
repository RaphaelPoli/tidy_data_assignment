## Steps description of run_anlysis.R script

This script is used with samsung data provided by coursera for tidying data course in data scientist training.
Data should be in your working directory in a folder named "UCI HAR Dataset" as it is when extracted directly.


### Step 1  of the assignment 
The script browses through the ./test and ./train folders of this dataset and loads the three .txt tables in those directories.
The procedure used for that could also load many other files 
because I first thought I would need the data in "Inertial Signals" folders.

It then gathers the training set and the test set together 
after havind gathered each together with the subject and activity columns


### Step 4 of the assignment (sorry not in order)

I did this before selecting columns to be able to check more easily if names are not mistakenly attributed. 
(if both sets have same length comparition is more clear)

Here the script renames all columns according to the lesson instructions:
instead of V1, V2, etc. it lends all names found in "features.txt" and matches them according to their numbers.
It then removes spectial characters, spaces and capital letters.


### Step 2 of the assignment 

Selects the columns with mean or standard deviation
also extracts the new name list in order to pass it to the melt function in 5


### Step 3 of the assignment 

Replaces the numbers in activity columns by activity names


### Step 5 of the assignment 

For step five I choosed to melt and dcast the data.
The result gives one line for each combination of subject and activity, measurements are then means
This make 180 lines (30*6) and 86 means for each line.
Each row is one specific observation, and each column a variable concerning this case.
variable names contain no capital letters, no space, no special characters and are explicit.

I kept the names from the original set because I thought they were in the same time compact and explicit.

