import os
import shutil
from zipfile import ZipFile
from datetime import datetime

# Get the current working directory and the OS-specific path separator
base_dir = os.getcwd()
os_sep = os.path.sep

# Print the base directory and path separator for debugging purposes
print(os_sep)
print(base_dir)

# Lists of files and directories to ignore
ignore_file_list = ['easter.py', 'isoparser.py', 'rebuild.py', 'relativedelta.py', 'rrule.py',
                    'tz.py', 'tzwin.py', 'utils.py', 'win.py', 'python-sast.py']
ignore_dir_list = ['layers']

# Initialize lists to store paths of files to be included in the zip file
py_file_list = []
zip_file_list = []

# Walk through the directory structure starting from base_dir for .py files
for r, d, f in os.walk(base_dir):
    for file in f:
        f_pass = True
        if file.endswith(".py"):  # Include .py files
            f_dir = os.path.join(r, file)
            if 'test' not in file and file not in ignore_file_list and not file.startswith('_'):
                for d in ignore_dir_list:
                    d_string = os_sep + d + os_sep
                    if d_string in f_dir:
                        f_pass = False
                        break
                if f_pass:
                    py_file_list.append(f_dir)
                else:
                    print('ignoring: {0}'.format(file))

# Walk through the directory structure starting from python folder for .zip files
python_dir = os.path.join(base_dir, 'python')
for r, d, f in os.walk(python_dir):
    for file in f:
        if file.endswith(".zip"):  # Include .zip files
            f_dir = os.path.join(r, file)
            zip_file_list.append(f_dir)

# Extract contents of found .zip files
extracted_files = []
for zip_file in zip_file_list:
    with ZipFile(zip_file, 'r') as zf:
        extract_path = os.path.join(base_dir, 'extracted_zip_files', os.path.basename(zip_file).replace('.zip', ''))
        zf.extractall(extract_path)
        for root, _, files in os.walk(extract_path):
            for file in files:
                extracted_files.append(os.path.join(root, file))

# Combine the lists of files to be included
file_list = py_file_list + extracted_files

# Print the list of files to be included for debugging purposes
print(file_list)

# Create a zip file with a name that includes the current date
dt_string = datetime.now().strftime('%Y%m%d')
zip_name = 'veracode_static_sast_{0}.zip'.format(dt_string)
base_file_name_list = []

# Add the collected files to the zip archive
with ZipFile(zip_name, 'w') as py_zip:
    for f in file_list:
        base_name = os.path.basename(f)
        if not base_name.startswith('_'):
            veracode_name = (f'{f.split(os_sep)[-3]}_{f.split(os_sep)[-2]}'.replace('-', '_') + '_' + base_name)[:255]
            py_zip.write(f, veracode_name)
            base_file_name_list.append(veracode_name)

# Optionally, clean up extracted files
shutil.rmtree(os.path.join(base_dir, 'extracted_zip_files'))

print(f"Created zip file: {zip_name}")
