DESTINATION_DIR=${DESTINATION_DIR:-$PWD}
MODULE_DIR=${MODULE_DIR:-$PWD}
ZIPFILE_NAME=${ZIPFILE_NAME:-layer}
echo "Module dir $MODULE_DIR"
echo "Destination dir $DESTINATION_DIR"

TARGET_DIR=$DESTINATION_DIR/$ZIPFILE_NAME
echo "Target dir $TARGET_DIR"
mkdir -p "$TARGET_DIR"
REQUIREMENTS_FILE_PATH=$MODULE_DIR/requirements.txt
python3 "$MODULE_DIR"/requirements_creator.py --file_path "$REQUIREMENTS_FILE_PATH"
pip install -r "$REQUIREMENTS_FILE_PATH" -t "$TARGET_DIR"/python
(cd "$TARGET_DIR" && zip -r "$DESTINATION_DIR"/"$ZIPFILE_NAME".zip ./* -x "*.dist-info*" -x "*__pycache__*" -x "*.egg-info*")
rm "$REQUIREMENTS_FILE_PATH"
rm -r "$TARGET_DIR"