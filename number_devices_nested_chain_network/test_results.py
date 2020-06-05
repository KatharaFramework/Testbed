import os
import re


def extract_start_time(folder, results):
    with open("%s/time_start.txt" % folder, "r") as start_time_file:
        matches = re.findall("real (.*)", start_time_file.read())

        results["start_time"] = float(matches[0])


def extract_clean_time(folder, results):
    with open("%s/time_clean.txt" % folder, "r") as clean_time_file:
        matches = re.findall("real (.*)", clean_time_file.read())

        results["clean_time"] = float(matches[0])


def extract_results():
    results = {}

    files = os.listdir("./labs")

    for folder in files:
        full_path = os.path.join(".", "labs", folder)

        if os.path.isdir(full_path):
            results[folder] = {}

            extract_start_time(full_path, results[folder])
            extract_clean_time(full_path, results[folder])

    return results


def write_results_on_file(results):
    with open("start_time_results.csv", "w") as start_time_results_file:
        start_time_results_file.write("Lab,Time\n")

    with open("clean_time_results.csv", "w") as clean_time_results_file:
        clean_time_results_file.write("Lab,Time\n")

    for lab_name in sorted(results.keys(), key=lambda x: int(x.split('lab_')[1])):
        with open("start_time_results.csv", "a") as start_time_results_file:
            start_time_results_file.write("%s,%s\n" % (lab_name, results[lab_name]["start_time"]))

        with open("clean_time_results.csv", "a") as clean_time_results_file:
            clean_time_results_file.write("%s,%s\n" % (lab_name, results[lab_name]["clean_time"]))


if __name__ == "__main__":
    test_results = extract_results()
    write_results_on_file(test_results)
