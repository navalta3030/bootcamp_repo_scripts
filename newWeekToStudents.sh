function reFormatNum() {
  argLength=${#1}

  if [[ argLength -eq 1 ]]; then
    echo "0${1}"
  else
    echo $1
  fi
}

userDesktopWorkspace="/c/Users/$(whoami)/Desktop"
pathToContent="${userDesktopWorkspace}/UCDavis/fullstack-ground/01-Class-Content"
pathToStudentRepo="${userDesktopWorkspace}/UCDavis/ucd-sac-fsf-pt-03-2020-u-c"

if [[ "$#" -ne 1  ]]; then
  echo "Usage: ./activitiesToStudents.sh [Week Number]"
else

  # pull latest content from source
  cd $pathToContent
  git reset --hard
  git clean -fd
  git pull origin master

  # clean the gitlab repository before
  cd $pathToStudentRepo
  git reset --hard
  git clean -fd

  weekNum=$(reFormatNum $1)

  # initiate new week name of folder (IE: pathToContent/02-css-bootstrap)
  newWeekDirName=$(echo ${pathToContent}/${weekNum}* | sed -E 's/^[^0-9].*Content\/([0-9]+.*)/\1/')

  # create the folder and also the activities folder
  mkdir ${pathToStudentRepo}/${newWeekDirName}
  mkdir ${pathToStudentRepo}/${newWeekDirName}/01-Activities


  activityNum=$(reFormatNum $num)

  # copy all content of 02-css-bootstrap/01-Activities but exclude solved
  rsync -av --progress ${pathToContent}/${weekNum}*/01*/* ${pathToStudentRepo}/${weekNum}*/01* --exclude Solved > /dev/null

  #  Utilities 
  activity=$(echo ${pathToContent}/${weekNum}*/01*/${activityNum}* | sed -E 's/^[^0-9].*Activities\/([0-9]+.*)/\1/')
  destination=$(echo ${pathToStudentRepo}/${weekNum}*/01* | sed -E 's/^.*(UCD.*)/\1/')

  barLength=$((${#activity} + ${#destination} + 4))

  printf '%.0s-' $(seq 1 $barLength)
  printf '\n'
  printf "$activity -> $destination"
  printf '\n'
  printf '%.0s-' $(seq 1 $barLength)
  printf '\n\n'

  # Copy the Homework and other utilities but exclude the 01-Activities(already done) and also the solution and grading rubrics.
  rsync -av --progress ${pathToContent}/${weekNum}* ${pathToStudentRepo} --exclude 01-Activities --exclude Solutions --exclude gradingRubrics > /dev/null

  # Reason we add this is for gitlab webhook to slack notification
  git add .
  git commit -m "Added new week $1" # Reason we add this is for gitlab webhook to slack notification
  git push origin master
fi
