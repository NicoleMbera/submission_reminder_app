#!/bin/bash

# Function to validate input (no special characters or spaces)
validate_input() {
    if [[ "$1" =~ [^a-zA-Z0-9_] ]]; then
        echo "Error: Name contains special characters or spaces. Please use only letters, numbers and underscores."
        return 1
    fi
    return 0
}

# Clear the screen and display welcome message
clear
echo "====================================================="
echo "   Submission Reminder App Environment Setup Tool    "
echo "====================================================="
echo

# Prompt the username
while true; do
    echo -n "Please enter your name (no spaces or special characters): "
    read user_name
    
    # Validate the input
    if validate_input "$user_name"; then
        break
    fi
done

# Create main directory
main_dir="submission_reminder_${user_name}"
echo -e "\nCreating application environment in $main_dir..."

if [ -d "$main_dir" ]; then
    echo "Warning: Directory $main_dir already exists."
    echo -n "Do you want to overwrite it? (y/n): "
    read response
    if [ "$response" != "y" ] && [ "$response" != "Y" ]; then
        echo "Setup aborted."
        exit 1
    fi
    rm -rf "$main_dir"
    echo "Existing directory removed."
fi

# Create main directory and sub-directories
mkdir -p "$main_dir"/{assets,config,modules}
echo "✓ Created main directory structure"

# Create and populate the config.env file
cat > "$main_dir/config/config.env" << 'EOF'
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF
echo "✓ Created config.env file"

# Create and populate the functions.sh file
cat > "$main_dir/modules/functions.sh" << 'EOF'
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}
EOF
echo "✓ Created functions.sh file"

# Create and populate the reminder.sh file
cat > "$main_dir/reminder.sh" << 'EOF'
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions $submissions_file
EOF
echo "✓ Created reminder.sh file"

# Create submissions.txt file with the original entries
cat > "$main_dir/assets/submissions.txt" << 'EOF'
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
EOF

# Prompt user to add 5 more student records
echo -e "\nYou need to add 5 more student records to the submissions.txt file."
echo "For each student, you'll need to provide the name, assignment, and submission status."

for i in {1..5}; do
    echo -e "\nStudent record #$i:"
    
    echo -n "Enter student name: "
    read student_name
    
    echo -n "Enter assignment name (e.g., Shell Navigation, Git, Shell Basics): "
    read assignment_name
    
    echo -n "Enter submission status (submitted/not submitted): "
    read submission_status
    
    # Validate submission status
    while [[ "$submission_status" != "submitted" && "$submission_status" != "not submitted" ]]; do
        echo "Error: Submission status must be either 'submitted' or 'not submitted'"
        echo -n "Enter submission status (submitted/not submitted): "
        read submission_status
    done
    
    # Append the new record to submissions.txt
    echo "$student_name, $assignment_name, $submission_status" >> "$main_dir/assets/submissions.txt"
    echo "✓ Added record for $student_name"
done

echo "✓ Created and populated submissions.txt file with all student records"

# Create the startup.sh script
cat > "$main_dir/startup.sh" << 'EOF'
#!/bin/bash

# Display banner
echo "=================================================="
echo "        SUBMISSION REMINDER APPLICATION           "
echo "=================================================="
echo

# Check if required files exist
if [ ! -f "./config/config.env" ]; then
    echo "Error: config.env file not found"
    exit 1
fi

if [ ! -f "./modules/functions.sh" ]; then
    echo "Error: functions.sh file not found"
    exit 1
fi

if [ ! -f "./reminder.sh" ]; then
    echo "Error: reminder.sh file not found"
    exit 1
fi

if [ ! -f "./assets/submissions.txt" ]; then
    echo "Error: submissions.txt file not found"
    exit 1
fi

# Make the reminder script executable if it's not already
if [ ! -x "./reminder.sh" ]; then
    chmod +x ./reminder.sh
    echo "Made reminder.sh executable"
fi

# Run the reminder application
echo "Starting the submission reminder application..."
echo "----------------------------------------------"
./reminder.sh

echo
echo "Application execution completed."
EOF
echo "✓ Created startup.sh file"

# Make the scripts executable
chmod +x "$main_dir/reminder.sh" "$main_dir/modules/functions.sh" "$main_dir/startup.sh"
echo "✓ Made scripts executable"

echo -e "\nEnvironment setup complete! Your application is ready in the '$main_dir' directory."
echo -e "To start the application, navigate to the directory and run ./startup.sh\n"
echo "cd $main_dir && ./startup.sh"