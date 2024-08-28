#!/bin/bash

PATH_TO_DIRECTORY=/data6/Users/joonblee/hw_singularity/

# Function to convert time (HH:MM:SS) to seconds
time_to_seconds() {
  IFS=: read -r hours minutes seconds <<< "$1"
  
  # Remove leading zeros
  hours=$((10#$hours))
  minutes=$((10#$minutes))
  seconds=$((10#$seconds))
  
  echo $((hours * 3600 + minutes * 60 + seconds))
}

# Function to calculate the running time
calculate_running_time() {
  start_time=$1
  end_time=$2

  start_seconds=$(time_to_seconds "$start_time")
  end_seconds=$(time_to_seconds "$end_time")

  # Check if start time is greater than end time (crossing midnight)
  if [ "$start_seconds" -gt "$end_seconds" ]; then
    # Add 24 hours (86400 seconds) to end time
    end_seconds=$((end_seconds + 86400))
  fi

  running_time=$((end_seconds - start_seconds))
  echo "$running_time"
}

# Initialize total time and count
total_time=0
file_count=0

# Process each file
for file in $PATH_TO_DIRECTORY/job*.out; do
  start_time=$(grep "Starting time" "$file" | awk '{print $4}')
  end_time=$(grep "End time" "$file" | awk '{print $4}')

  running_time=$(calculate_running_time "$start_time" "$end_time")

  # Convert running time back to HH:MM:SS format
  hours=$((running_time / 3600))
  minutes=$(((running_time % 3600) / 60))
  seconds=$((running_time % 60))

  printf "File: %s - Running time: %02d:%02d:%02d\n" "$file" "$hours" "$minutes" "$seconds"

  total_time=$((total_time + running_time))
  file_count=$((file_count + 1))
done

# Calculate the average running time in seconds
if [ "$file_count" -gt 0 ]; then
  average_time=$((total_time / file_count))

  # Convert average time back to HH:MM:SS format
  hours=$((average_time / 3600))
  minutes=$(((average_time % 3600) / 60))
  seconds=$((average_time % 60))

  printf "Average running time: %02d:%02d:%02d\n" "$hours" "$minutes" "$seconds"
else
  echo "No files found."
fi
