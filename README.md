# Kathara Testbed
In this repository you'll find scripts to test Kathara performances.

## chain_test_kathara_*

The folder contains scripts to test the latency of Kathara.

The script will build a various labs consisting in a chain of `N+2` machines, where:
- The first and the last machines of the chain are a client and a server, respectively.
- All the intermediate machines are routers.
- Two machines that are consecutive in the chain are connected by a virtual LAN.

Using `ping`, the script measures the RTT between the client and the server.

### Usage 

```./test.sh -r N_ROUTERS```

Will execute the script ranging `N` from 0 to `N_ROUTES`, will save the results in the lab folder and will generate three CSV files.

- `start_time_results.csv`: each line will contain `N` and the elapsed time to start the lab.
- `clean_time_results.csv`: each line will contain `N` and the elapsed time to cleanup the lab.
- `ping_results.csv`: each line will contain `N` and the average of 5 pings from server to client.