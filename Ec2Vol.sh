#!/bin/bash

# Configuration
EMAIL_RECIPIENT="your-email@example.com"
SSH_KEY="path/to/your/key.pem"
OUTPUT_FILE="/tmp/disk_space_report.txt"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# List of EC2 instances (not using a list, for initial run)
declare -A instances=(
    ["instance1"]="user@ec2-xx-xx-xx-1.compute.amazonaws.com"
    ["instance2"]="user@ec2-xx-xx-xx-2.compute.amazonaws.com"
    ["instance3"]="user@ec2-xx-xx-xx-3.compute.amazonaws.com"
    ["instance4"]="user@ec2-xx-xx-xx-4.compute.amazonaws.com"
    ["instance5"]="user@ec2-xx-xx-xx-5.compute.amazonaws.com"
    ["instance6"]="user@ec2-xx-xx-xx-6.compute.amazonaws.com"
    ["instance7"]="user@ec2-xx-xx-xx-7.compute.amazonaws.com"
    ["instance8"]="user@ec2-xx-xx-xx-8.compute.amazonaws.com"
    ["instance9"]="user@ec2-xx-xx-xx-9.compute.amazonaws.com"
    ["instance10"]="user@ec2-xx-xx-xx-10.compute.amazonaws.com"
)

# Create or clear the output file
echo "Disk Space Report - Generated on $DATE" > $OUTPUT_FILE
echo "========================================" >> $OUTPUT_FILE

#  to check disk space on a remote instance
check_disk_space() {
    local instance_name=$1
    local instance_address=$2
    
    echo -e "\nChecking disk space on $instance_name ($instance_address)..." >> $OUTPUT_FILE
    
    # Try to connect with timeout to avoid hanging
    if ssh -i $SSH_KEY -o ConnectTimeout=10 -o StrictHostKeyChecking=no $instance_address 'df -h' >> /dev/null 2>&1; then
        # Get disk usage information
        echo "Disk Usage:" >> $OUTPUT_FILE
        ssh -i $SSH_KEY $instance_address 'df -h | grep -vE "^tmpfs|^devtmpfs|^udev"' >> $OUTPUT_FILE
        
        # Check if there are multiple disks
        local disk_count=$(ssh -i $SSH_KEY $instance_address 'df -h | grep -vE "^tmpfs|^devtmpfs|^udev" | grep -v "^Filesystem" | wc -l')
        
        if [ $disk_count -gt 1 ]; then
            echo "Multiple disks detected ($disk_count disks)" >> $OUTPUT_FILE
        fi
        
        echo "----------------------------------------" >> $OUTPUT_FILE
    else
        echo "ERROR: Unable to connect to $instance_name" >> $OUTPUT_FILE
        echo "----------------------------------------" >> $OUTPUT_FILE
    fi
}

# Main execution
echo "Starting disk space check across EC2 instances..."

# Check each instance
for instance_name in "${!instances[@]}"; do
    check_disk_space "$instance_name" "${instances[$instance_name]}"
done

# Email the report
if [ -f $OUTPUT_FILE ]; then
    # Create email content
    cat << EOF | mail -s "EC2 Disk Space Report - $DATE" $EMAIL_RECIPIENT
Please find attached the disk space report for EC2 instances.

This report was automatically generated on $DATE.

EOF
    # Attach and send the report
    uuencode $OUTPUT_FILE "disk_space_report.txt" | mail -s "EC2 Disk Space Report - $DATE" $EMAIL_RECIPIENT
    
    echo "Report has been generated and sent to $EMAIL_RECIPIENT"
else
    echo "Error: Report file was not created"
fi
