#!/bin/sh

SOURCE_ROOT=`pwd`


# Configuration:
CODE_DIR="/" # relative to SOURCE_ROOT
LANGUAGE_FILE="strings.txt" # relative to CODE_DIR

TEMP_DIR="/tmp"
# Vars
USED_KEYS_FILE=`mktemp "$TEMP_DIR/used_keys.XXXXX"`
TRANSLATED_KEYS_FILE=`mktemp "$TEMP_DIR/translated_keys.XXXXX"`
DIFF_FILE=`mktemp "$TEMP_DIR/diff_keys.XXXXX"`

grep -Ir "NSLocalizedStringFromTable(@" "$SOURCE_ROOT/$CODE_DIR" | sed -E 's/.*NSLocalizedStringFromTable\(@"(([^"]|\\\")+).*/\1/g' |  sort | uniq > "$USED_KEYS_FILE"
#Catching the second localized string on the same line
grep -Ir "NSLocalizedStringFromTable(@" "$SOURCE_ROOT/$CODE_DIR" | sed -E 's/.*NSLocalizedStringFromTable\(@"(([^"]|\\\")+).*NSLocalizedStringFromTable.*/\1/g' | grep -v 'NSLocalizedStringFromTable' | sort | uniq >> "$USED_KEYS_FILE"
cat $USED_KEYS_FILE | sort | uniq > "$USED_KEYS_FILE"
grep "[^\[]\[[^\[]" "$SOURCE_ROOT/$CODE_DIR/$LANGUAGE_FILE" | sed -E 's/.*\[(.*)\].*/\1/' | sort | uniq > "$TRANSLATED_KEYS_FILE"

diff -u "$USED_KEYS_FILE" "$TRANSLATED_KEYS_FILE" > "$DIFF_FILE"
echo "Unused translations:"
cat $DIFF_FILE | egrep '^(\+)\w' | cut -c2- | sed -E 's/(.*)/	[\1]/g'

cat $DIFF_FILE | egrep '^(\-)\w' | cut -c2- | sed -E 's/(.*)/	[\1]/g' >> "$LANGUAGE_FILE"
echo "\nAdded missing translations to $LANGUAGE_FILE"
