import os
from zipfile import ZipFile
from datetime import datetime

base_dir = os.getcwd()
os_sep = os.path.sep

print(os_sep)
print(base_dir)

ignore_file_list = ['easter.py', 'isoparser.py', 'rebuild.py', 'relativedelta.py', 'rrule.py',
            'tz.py', 'tzwin.py', 'utils.py', 'win.py', 'veracode.py']
ignore_dir_list = ['layers']

file_list = []

for r, d, f in os.walk(base_dir):
    for file in f:
        f_pass = True
        if file.endswith(".py"): 
            f_dir = os.path.join(r, file)
            if 'test' not in file and file not in ignore_file_list and not file.startswith('_'):
                for d in ignore_dir_list:
                    d_string = os_sep + d + os_sep
                    if d_string in f_dir:
                        f_pass = False
                        break
                    # print(d_string)
                # print(f_dir)
                if f_pass:
                    file_list.append(f_dir)
                else:
                    print('ignoring: {0}'.format(file))
                    pass
print(file_list)
dt_string = datetime.now().strftime('%Y%m%d')
zip_name = 'veracode_static_sast_{0}.zip'.format(dt_string)
base_file_name_list = []
with ZipFile(zip_name, 'w') as py_zip:
    for f in file_list:
        base_name = os.path.basename(f)
        if not base_name.startswith('_'):
            veracode_name = (f'{f.split(os_sep)[-3]}_{f.split(os_sep)[-2]}'.replace('-', '_') + '_' + base_name)[:255]
            py_zip.write(f, veracode_name)
            base_file_name_list.append(veracode_name)