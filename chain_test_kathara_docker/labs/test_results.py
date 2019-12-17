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
        pings = list(map(lambda x: float(x), matches))

        min_ping = min(pings)
        max_ping = max(pings)

        if matches:
            results["ping_avg"] = sum(pings) / len(pings)
            results["ping_min"] = min_ping
            results["ping_max"] = max_ping
            results["ping_std_max"] = results["ping_avg"] + stdev(pings)
            results["ping_std_min"] = results["ping_avg"] - stdev(pings)
        else:
            results["ping_avg"] = "None"
            results["ping_min"] = "None"
            results["ping_max"] = "None"
            results["ping_std_max"] = "None"
            results["ping_std_min"] = "None"


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
