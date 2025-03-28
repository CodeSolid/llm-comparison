#!/bin/bash
# dedup.sh - Find duplicate files between two directories and generate a script to delete duplicates

# Ensure we have exactly two arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <keep_dir> <delete_dups_dir>"
    echo "  keep_dir: Directory with files to keep"
    echo "  delete_dups_dir: Directory to scan for duplicates to delete"
    exit 1
fi

# Check if both arguments are directories
if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a directory"
    exit 1
fi

if [ ! -d "$2" ]; then
    echo "Error: '$2' is not a directory"
    exit 1
fi

# Store arguments in variables with clear names
KEEP_DIR="$1"
DELETE_DUPS_DIR="$2"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Create temp file paths
KEEP_TEMP="/tmp/com.codesolid.${TIMESTAMP}.keep"
DELETE_TEMP="/tmp/com.codesolid.${TIMESTAMP}.delete_dups"

# Function to scan directory and output filename, path, and checksum
scan_directory() {
    local dir="$1"
    local output_file="$2"
    
    # Clear output file if it exists
    > "$output_file"
    
    # Find all regular files, calculate SHA256 checksum, and format output
    find "$dir" -type f -print0 | while IFS= read -r -d '' file; do
        # Extract just the filename with extension
        filename=$(basename "$file")
        # Calculate checksum
        checksum=$(sha256sum "$file" | cut -d ' ' -f 1)
        # Write to output file: filename, full path, checksum
        echo "$filename|$file|$checksum" >> "$output_file"
    done
}

echo "Scanning directory '$KEEP_DIR'..."
scan_directory "$KEEP_DIR" "$KEEP_TEMP"

echo "Scanning directory '$DELETE_DUPS_DIR'..."
scan_directory "$DELETE_DUPS_DIR" "$DELETE_TEMP"

echo "Generating delete.sh script..."

# Create delete.sh with header
cat > delete.sh << 'EOF'
#!/bin/bash
# delete.sh - Auto-generated script to delete duplicate files
# Generated by dedup.sh on $(date)

# Count of files to be deleted
count=0

# Function to safely delete a file
delete_file() {
    if [ -f "$1" ]; then
        rm "$1"
        echo "Deleted: $1"
        count=$((count + 1))
    else
        echo "Warning: File not found: $1"
    fi
}

echo "Starting deletion of duplicate files..."

EOF

# Make delete.sh executable
chmod +x delete.sh

# Process the files and find duplicates
while IFS= read -r keep_line; do
    # Extract filename and checksum from keep directory
    keep_filename=$(echo "$keep_line" | cut -d '|' -f 1)
    keep_checksum=$(echo "$keep_line" | cut -d '|' -f 3)
    
    # Look for matches in delete_dups directory
    grep -F "|$keep_checksum" "$DELETE_TEMP" | while IFS= read -r dup_line; do
        dup_filename=$(echo "$dup_line" | cut -d '|' -f 1)
        dup_path=$(echo "$dup_line" | cut -d '|' -f 2)
        
        # If the filenames match and checksums match, add to delete.sh
        if [ "$keep_filename" = "$dup_filename" ]; then
            echo "delete_file \"$dup_path\"" >> delete.sh
        fi
    done
done < "$KEEP_TEMP"

# Add final count report to delete.sh
cat >> delete.sh << 'EOF'

echo "Deletion complete. $count duplicate files were deleted."
EOF

echo "Script generated: delete.sh"
echo "Run './delete.sh' to delete the duplicate files."
echo "Temporary files created: $KEEP_TEMP and $DELETE_TEMP"