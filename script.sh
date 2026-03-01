#!/bin/bash


### config ###

URL="https://oblenergo.cv.ua/shutdowns"
TIMETABLES_DIR="chernivtsi-power-outages-history-timetables"

GIT_USER_NAME=${GIT_USER_NAME:-"github-actions[bot]"}
GIT_USER_EMAIL=${GIT_USER_EMAIL:-"github-actions[bot]@users.noreply.github.com"}


### setup ###

TIMESTAMP=$(TZ='Europe/Kyiv' date +%Y-%m-%d_%H-%M-%S)
TODAY_FILE="${TIMESTAMP}-today.html"
NEXT_FILE="${TIMESTAMP}-next.html"

cd "$TIMETABLES_DIR" || exit 1


### fetch ###

curl -L -o "$TODAY_FILE" "$URL"
curl -L -o "$NEXT_FILE" "${URL}/?next"


if [ ! -f "$TODAY_FILE" ] || [ ! -f "$NEXT_FILE" ]; then
    echo "Error: Failed to fetch one or both URLs"
    exit 1
fi

sed -i 's/Cloudflare Ray ID: <strong class="font-semibold">.*<\/strong>//g' "$TODAY_FILE" "$NEXT_FILE"

if diff -w -B "$TODAY_FILE" "$NEXT_FILE"; then
    rm "$NEXT_FILE"
fi


### git ###

git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

git add *.html


if git diff --staged --quiet; then
    echo "No changes to commit"
    exit 0
fi

git commit -m "snapshot $TIMESTAMP"

git push
