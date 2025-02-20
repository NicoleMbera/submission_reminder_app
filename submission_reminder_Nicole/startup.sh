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
