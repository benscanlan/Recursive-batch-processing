#!/bin/bash
# Comment: create variable of filename.zip in format "filename"
directory="$(basename $1 .zip)"
#Comment: make directory with the same name and unzip zip contents to directory
mkdir "$directory"
unzip "$1" -d "$directory"

# Main program while loop: list then grep for something between _ and _a but dont include _a then remove duplicates with sort -unique then reads through list of unique user ID's making a directory for each user.
ls "$directory" | grep -o -P '(?<=_).*(?=_a)' | sort -u | while read i
    do
        echo working with directory: $i
        mkdir $directory/$i
        mv $directory/*${i}_attempt* $directory/$i

# Create readme.txt with user comments only.
        grep 'There is no student submission text data for this assignment.' $directory/$i/*.txt && grep 'There are no student comments for this assignment.' $directory/$i/*.txt
        if [ $? -eq 0 ]; then
            rm $directory/$i/*.txt
        else
            grep 'There is no student submission text data for this assignment.' $directory/$i/*.txt
            if [ $? -ne 0 ]; then
                awk '/Submission Field:/{flag=1;next}/Comments:/{flag=0}flag' $directory/$i/*.txt >> $directory/$i/readme.txt
            fi

            grep 'There are no student comments for this assignment.' $directory/$i/*.txt
            if [ $? -ne 0 ]; then
                awk '/Comments:/{flag=1;next}/Files:/{flag=0}flag' $directory/$i/*.txt >> $directory/$i/readme.txt
            fi
            rm $directory/$i/*${i}_attempt*.txt
        fi

#log file for each user who has submitted neither a compressed nor archived file.
        file $directory/$i/*${i}_attempt* | grep -o -P 'gzip|POSIX|Zip'
        if [ $? -ne 0 ]; then
            #echo user who has submitted neither a compressed nor archived file:{i} >> errors.log
            #file $directory/$i/*${i}_attempt* >> $directory/errors.txt
            grep $i $directory/errors.txt
            if [ $? -ne 0 ]; then
                echo $i >> $directory/errors.txt
            fi
        fi

#GUNZIP STUFF
        for a in $directory/$i/*${i}_attempt*
        do
            file "$a" | grep -o -P 'gzip'
            if [ $? -eq 0 ]; then
                gunzip "$a"
                if [ $? -ne 0 ]; then
                    mv "$a" $directory/$i/${i}_attempt_file.tar.gz
                    gunzip $directory/$i/${i}_attempt_file.tar.gz
                fi
            fi
        done
#EXTRACT TARBALL STUFF
        for a in $directory/$i/*${i}_attempt*
        do

            file "$a" | grep -o -P 'POSIX'
            if [ $? -eq 0 ]; then
                tar -xvf "$a" -C $directory/$i
                if [ $? -ne 0 ]; then
                    mv "$a" $directory/$i/${i}_attempt_file.tar
                    tar -xvf $directory/$i/${i}_attempt_file.tar -C $directory/$i
                fi
            fi
#UNZIP STUFF
            file "$a" | grep -o -P 'Zip'
            if [ $? -eq 0 ]; then
                unzip "$a" -d $directory/$i
                if [ $? -ne 0 ]; then
                    mv "$a" $directory/$i/${i}_attempt_file.zip
                    unzip $directory/$i/${i}_attempt_file.zip -d $directory/$i
                fi
            fi
        done
    done