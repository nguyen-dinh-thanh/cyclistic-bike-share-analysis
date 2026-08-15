"""
=============================================================================
Script: 01_data_upload.py
Purpose: To overcome BigQuery's 10MB local upload limit by automating 
         the batch upload of 12 CSV files directly from Google Colab / Drive.
Result:  Successfully pushes 12 monthly CSV files to BigQuery datasets 
         as individual tables (e.g., tripdata_202501).
=============================================================================
"""
import glob
import os
import pandas as pd
from google.colab import auth, drive

# 1. Authenticate Account & Mount Google Drive
auth.authenticate_user()
drive.mount('/content/drive')

# 2. Specify BigQuery information
project_id = 'stable-ring-382611'
dataset_id = 'cyclistic_case_study'

# 3. Path to the folder containing the 12 CSV files on Google Drive
folder_path = '/content/drive/MyDrive/Cyclistic_Data'

# 4. Find all files with the .csv extension in the directory.
csv_files = glob.glob(os.path.join(folder_path, "*.csv"))

print(f"Found {len(csv_files)} CSV files. Starting the data upload process...\n")

# 5. Automatically loop through and process each file
for file in csv_files:
    # Get the file name (e.g., '202501-divvy-tripdata.csv')
    file_name = os.path.basename(file)

    # Automatically set the table name based on the file name (e.g., 'tripdata_202501')
    # Extract the first 6 digits representing YYYYMM from the file name
    clean_name = file_name.split('-')[0]
    table_name = f"tripdata_{clean_name}"

    table_id = f"{project_id}.{dataset_id}.{table_name}"

    print(f"🔄 Reading file: {file_name}...")
    df = pd.read_csv(file)

    print(f"⬆️  Pushing data to BigQuery table: {table_name}...")
    df.to_gbq(
        destination_table=table_id, project_id=project_id, if_exists='replace'
    )
    print(f"✅ Completed table {table_name}!\n" + "-" * 40)

print("🎉 ALL 12 FILES HAVE BEEN SUCCESSFULLY UPLOADED TO BIGQUERY!")
