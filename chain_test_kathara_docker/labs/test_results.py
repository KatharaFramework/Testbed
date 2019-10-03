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


def extract_ping_time(folder, results):
    with open("%s/ping.txt" % folder, "r") as ping_file:
        matches = re.findall("time=(.*) ", ping_file.read())

        if matches:
            results["ping_avg"] = sum(map(lambda x: float(x), matches)) / 5
        else:
            results["ping_avg"] = "None"


def extract_results():
    results = {}

    files = os.listdir(".")

    for folder in files:
        if os.path.isdir(folder):
            results[folder] = {}

            extract_start_time(folder, results[folder])
            extract_clean_time(folder, results[folder])
            extract_ping_time(folder, results[folder])

    return results


def write_results_on_file(results):
    with open("start_time_results.csv", "w") as start_time_results_file:
        start_time_results_file.write("Lab,Time\n")

    with open("clean_time_results.csv", "w") as clean_time_results_file:
        clean_time_results_file.write("Lab,Time\n")

    with open("ping_results.csv", "w") as ping_results_file:
        ping_results_file.write("Lab,AvgTime\n")

    for lab_name in sorted(results.keys(), key=lambda x: int(x.split('lab_')[1])):
        with open("start_time_results.csv", "a") as start_time_results_file:
            start_time_results_file.write("%s,%s\n" % (lab_name, results[lab_name]["start_time"]))

        with open("clean_time_results.csv", "a") as clean_time_results_file:
            clean_time_results_file.write("%s,%s\n" % (lab_name, results[lab_name]["clean_time"]))

        with open("ping_results.csv", "a") as ping_results_file:
            ping_results_file.write("%s,%s\n" % (lab_name, results[lab_name]["ping_avg"]))


if __name__ == "__main__":
    test_results = extract_results()
    write_results_on_file(test_results)
