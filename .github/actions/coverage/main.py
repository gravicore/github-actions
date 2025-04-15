import os
import csv
import json


def get_jacoco_files(base_path="./java"):
    jacoco_files = []
    for dir_name in os.listdir(base_path):
        target_dir = os.path.join(base_path, dir_name, "target", "jacoco-ut")
        jacoco_path = os.path.join(target_dir, "jacoco.csv")
        if os.path.isfile(jacoco_path):
            jacoco_files.append((dir_name, jacoco_path))
    return jacoco_files


def parse_jacoco_csv(file_path):
    data = []
    with open(file_path, newline="") as csvfile:
        csvreader = csv.DictReader(csvfile)
        for row in csvreader:
            data.append(row)
    return data


def parse_java(base_path="./java"):
    jacoco_files = get_jacoco_files(base_path)
    coverage = []
    for folder_name, file_path in jacoco_files:
        coverage += list(map(lambda row: {
            "filename": f"{base_path.replace('./', '')}/{folder_name}/src/main/{row['PACKAGE'].replace('.', '/')}/{row['CLASS']}.java",
            "coverage": round(float(row["LINE_COVERED"]) * 100 / (float(row["LINE_MISSED"]) + float(row["LINE_COVERED"])), 2)
        }, parse_jacoco_csv(file_path)))
    return coverage


def get_uncovered_pyton(base_path="./python", coverage=[], data={}):
    python_files = []
    for root, _, files in os.walk(base_path):
        for file in files:
            if not any(path in file for path in ["test_", "_test.py", "__pycache__"]) and file.endswith(".py"):
                python_files.append(os.path.join(root, file).replace("./", ""))
    for file in [py for py in python_files if py not in data["files"].keys()]:
        coverage.append({
            "filename": file,
            "coverage": round(0, 2)
        })


def parse_python(base_path="./python"):
    coverage = []
    try:
        with open(f"{base_path}/coverage.json", "r") as file:
            data = json.load(file)
            for key in data["files"].keys():
                coverage.append({
                    "filename": f"{key}",
                    "coverage": round(data["files"][key]["summary"]["percent_covered"], 2)
                })
            get_uncovered_pyton(base_path, coverage, data)
    except json.JSONDecodeError as e:
        print("Invalid JSON:", e)
    return coverage


def main():
    java_coverage = parse_java()
    python_coverage = parse_python()
    print(json.dumps({
        "java": java_coverage,
        "python": python_coverage
    }, indent=4))


if __name__ == "__main__":
    main()
