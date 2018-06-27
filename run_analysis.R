
#first I created functions that will be practical in other cases

read_all<-function(directory){#inputs the path to files, and creates global environement data frames named after the filename (removing extension)
        setwd(directory)
        temp = list.files(pattern="*.txt")
        list2env(lapply(setNames(temp, make.names(tolower(gsub("*.txt$", "", temp)))),read.table),.GlobalEnv)
        list_names<-tolower(gsub("*.txt$", "", temp))
        return (list_names)
}


load_files_in_ram<-function(wd,list_directory){#this function loads into ram all listed directories using read_all function (selects only .txt)
        1->count
        for (dir in list_directory){#cycles thru given folders
                setwd(wd)
                print(dir)
                if (count==1){#first directory (create result variable: data_list_names)
                        data_list_names<-read_all(dir)#creates one dataframe per file named after the filename wihtout extention
                    
                }else{#all_other directories(append to the result variable)
                        data_list_names_2<-read_all(dir)#creates one dataframe per file named after the filename wihtout extention
                        data_list_names<-list.append(data_list_names, data_list_names_2)
                }
                count<-count+1
                print ("length of list names")
                print (length(data_list_names))
        }
        return (data_list_names)
}



charlist_remove<-function(vector,charlist){#this function removes all characters from charlist that are found in vector
        string_split <- strsplit(charlist, "")[[1]]
        for (char in string_split){
                vector<-gsub(char, "", vector, fixed = TRUE)
                }
        return (vector)
        
        }

# loading the necessary libraries

library(rlist)
library(reshape2)
library(dplyr)



#here starts the assignement process
#--------------------------------------------------------------------------------------
#step 1 : load and gather the train and test datasets
#I added the subject and activity column for later as specified in this paper
# https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/
wd_base<-getwd()
wd<-paste0(wd0,"/UCI HAR Dataset/")
print (wd)
#
#list_directory<-c("./train/","./test/","./test/Inertial Signals/","./train/Inertial Signals/")# could be used to load "Inertial Signals" folders
list_directory<-c("./test/","./train/")#to speed tests and then after realising I just need those folders

print ("first loop adding all files in RAM")#(skipped for testing)
#this function loads into ram all listed directories using read_all function (selects only .txt)
data_list_names<-load_files_in_ram(wd,list_directory)

print ("second loop: joining data frames")


#creating the list of dataframe to join
data_list<-eval(parse(text=data_list_names[[1]]))#this is a dummy it will be doubled TO be removed!!
for (data_name in data_list_names){
        data_list<-list.append(data_list, eval(parse(text=data_name)))
}
data_list[1]<-NULL#removing dummy
print ("data list length")
print (length(data_list))


#aggregating
#this works only with the current data set that has two directories with 3 files
test<-do.call(cbind, data_list[1:3])
train<-do.call(cbind, data_list[4:6])
result<-rbind(train,test)

#-----------------------------------------------------------------------------------------------
#now renaming the columns (step 4 sorry not in order)


#reading the names of the columns from the description file
setwd(wd)
explicit_colnam<-read.table("features.txt", stringsAsFactors=FALSE)
mean_names<-explicit_colnam[(grepl("mean",tolower(explicit_colnam$V2)))|(grepl("std",tolower(explicit_colnam$V2))),]


#extracting names in feature file and ordering them into the dataframe according to detected number
names<-tolower(charlist_remove(explicit_colnam$V2, "-(), "))
first_name<-"subject"
last_name<-"activity"
names(result)<-c(first_name,names(result)[2:562],last_name)
vector_num<-as.numeric(gsub("\\D","",names(result)))
ordered_names<-c("")#dummy to be removed
for (v in vector_num){#to be sure that the names in features file are in the same order than the corresponding columns of the data frame
        name_at_v<-explicit_colnam$V2[which((as.numeric(explicit_colnam$V1)==v))]
        ordered_names<-c(ordered_names,name_at_v)
}


#Now creating tidy names (only lowcase, no special character,no underscore as specified in the lesson)
names<-tolower(charlist_remove(explicit_colnam$V2, "-(), "))
ordered_names<-tolower(charlist_remove(ordered_names, "-(), "))[2:562]#removing dummy
names(result)<-c(first_name,ordered_names,last_name)



#-------------------------------------------------------------------------------------------
#step 2 of the assignement selecting columns for with mean and std

result2<-result[,(names(result)=="activity"|names(result)=="subject"|grepl("mean",names(result))|grepl("std",names(result)))]

vector_measurement_names<-names(result2)[2:87]#will be used by melt


#-------------------------------------------------------------------------------------------
#step 3 use descriptive activity names

result3<-result2

#create a vector of activity names
activity_name<-function(number){
        activities<-tolower(c("WALKING","WALKINGUPSTAIRS","WALKINGDOWNSTAIRS","SITTING","STANDING","LAYING"))
        return (activities[number])
}
vector<-c(0)#creating the vector with new names according to numbers
for (number in result3$activity){
        vector<-c(vector, activity_name(number))
}
vector<-vector[2:length(vector)]#removing dummy
result3$activity<-vector#replacing data here


#------------------------------------------------------------------------------------
#step 4 four has been done while loading


#-------------------------------------------------------------------------------------------
# for step 5 of assignment I propose to melt and then group_by subject

melted<-melt(result3,id=c("subject","activity"),measure.vars=vector_measurement_names)
result4<-dcast(melted, activity+subject~variable,mean)
result_final<-group_by(result4, subject)
setwd(wd_base)
write.table(result_final,"final_result_raphael_poli.txt",row.names=FALSE)

print ("Done. Final result written in final_result_raphael_poli.txt in working directory")

#accessory dataframes
by_activity<-aggregate(. ~ activity, result_final[-2], mean)
by_subject<-aggregate(. ~ subject, result_final[-1], mean)
