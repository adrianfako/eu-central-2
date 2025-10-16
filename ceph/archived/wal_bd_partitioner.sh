#!/bin/bash

# Configuration for 3TB disks
DISK_SIZE=960  # 3TB in GB (approximate)

# Define partition sizes in GB
# Each line represents: WAL size, DB size

# SSD 1 and 2
# PARTITIONS=(
#   "30 120"
#   "30 120"
#   "30 120"
#   "30 120"
#   "30 120"
# )

# SSD 3 and 4
PARTITIONS=(
  "30 120"
  "60 740"
)

# Replace with your disk device
DISK="/dev/sdr"  # CHANGE THIS to your actual device!

# Safety check
read -p "This will partition $DISK. All data will be lost! Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Operation cancelled."
  exit 1
fi

# Create new GPT partition table
echo "Creating new GPT partition table on $DISK..."
parted $DISK mklabel gpt

# Start position in GB
START=0
PARTITION_NUM=1

# Create partitions with specified sizes
for PAIR in "${PARTITIONS[@]}"; do
  read WAL_SIZE DB_SIZE <<< "$PAIR"
  
  # Create WAL partition
  END=$((START + WAL_SIZE))
  echo "Creating WAL partition ${PARTITION_NUM}: ${START}GB to ${END}GB (${WAL_SIZE}GB)"
  parted $DISK mkpart primary ${START}GB ${END}GB
  parted $DISK name $PARTITION_NUM WAL-$((PARTITION_NUM/2+PARTITION_NUM%2))
  
  # Update start position for DB partition
  START=$END
  PARTITION_NUM=$((PARTITION_NUM + 1))
  
  # Create DB partition
  END=$((START + DB_SIZE))
  echo "Creating DB partition ${PARTITION_NUM}: ${START}GB to ${END}GB (${DB_SIZE}GB)"
  parted $DISK mkpart primary ${START}GB ${END}GB
  parted $DISK name $PARTITION_NUM DB-$((PARTITION_NUM/2))
  
  # Update start position for next pair
  START=$END
  PARTITION_NUM=$((PARTITION_NUM + 1))
  
  # Check if we've exceeded disk size
  if [ $START -ge $DISK_SIZE ]; then
    echo "Warning: Reached end of disk at partition $PARTITION_NUM"
    break
  fi
done

# Show final partition layout
echo "Partition layout:"
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT $DISK

# Calculate remaining space
REMAINING=$((DISK_SIZE - START))
if [ $REMAINING -gt 0 ]; then
  echo "Remaining unused space: ${REMAINING}GB"
fi