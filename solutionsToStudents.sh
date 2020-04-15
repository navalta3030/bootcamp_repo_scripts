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

if [[ "$#" -ne 2 ]]; then
  echo "Usage: ./solutionsToStudents.sh [Week Number] [End Activity]"
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

  for num in $(seq 0 $2); do
    activityNum=$(reFormatNum $num)

    # verify that we have a solved folder within the activity
    if [[ -n "$(ls ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved 2>/dev/null)" ]]; then

      # copy the content recursively 
      cp -r ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved ${pathToStudentRepo}/${weekNum}*/01*/${activityNum}*
      # still not sure what this one is for
      pathToSolved=$(cd ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved; pwd)

      source=$(echo ${pathToContent}/${weekNum}*/01*/${activityNum}*/Solved | sed -E 's/.*Activities\/([0-9]+.*)/\1/')
      destination=$(echo ${pathToStudentRepo}/${weekNum}*/01*/${activityNum}* | sed -E 's/^.*(UCD.*)/\1/')

      barLength=$((${#source} + ${#destination} + 4))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      printf "$source -> $destination"
      printf '\n'
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    else
      activity=$(echo ${pathToContent}/${weekNum}*/01*/${activityNum}* | sed -E 's/.*Activities\/([0-9]+.*)/\1/')
      tail="/Solved Not Found"
      barLength=$((${#activity} + ${#tail}))

      printf '%.0s-' $(seq 1 $barLength)
      printf '\n'
      echo "${activity}${tail}"
      printf '%.0s-' $(seq 1 $barLength)
      printf '\n\n'
    fi 
  done

  # Reason we add this is for gitlab webhook to slack notification
  git add .
  git commit -m "Added activity $2 soln for week $1" # Reason we add this is for gitlab webhook to slack notification
  git push origin master
fi