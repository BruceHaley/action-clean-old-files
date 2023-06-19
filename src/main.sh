source "$PR_SIZE_LABELER_HOME/src/github.sh"

main(){

export GITHUB_TOKEN="$1"
export DIR="$2"
export DAYS="$4"

now=$(date -d 'now' +%s)
branch_name=delete_old_migrations_${now}

git checkout -b ${branch_name};

X_DAYS_AGO_TIMESTAMP=$(date -d "${DAYS} days ago" +%s)
echo "X_DAYS_AGO_TIMESTAMP=" $X_DAYS_AGO_TIMESTAMP

# borrar los archivos con más de x dias de antiguedad
cd ${DIR};
for file in *.* ;
do
  echo "file=" "/${DIR}/${file}";
  echo "log -1=" $(git log --full-history -- "${DIR}/${file}")

  # Get the timestamp of the last commit that modified this file
  LAST_MODIFIED_TIMESTAMP=$(git log -1 --format="%at" -- "${DIR}/${file}")
  echo "LAST_MODIFIED_TIMESTAMP=" $LAST_MODIFIED_TIMESTAMP

  if [ "$LAST_MODIFIED_TIMESTAMP" -lt "$X_DAYS_AGO_TIMESTAMP" ]
  then
    rm -v $file
    echo "Removed"
  fi
done;


git add . ;
git -c user.name="GitHub Actions" -c user.email="actions@github.com" \
        commit -m "Delete old migrations" ;
git push --set-upstream origin "HEAD:${branch_name}";

github::create_pr $3 ${branch_name} "$5"

}
