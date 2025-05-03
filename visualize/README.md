# Traffic Matrix Generator

This script parses a flow completion time file (`fct.txt`) and generates a traffic matrix showing the total bytes sent between each pair of nodes. It also outputs the total simulation time in milliseconds.

## Usage

```bash
python traffic_matrix.py <input_fct.txt> <output_matrix.txt>
```

- `<input_fct.txt>`: Path to the input file containing flow records (see format below).
- `<output_matrix.txt>`: Path to the output file where the traffic matrix and total time will be saved.

## Input File Format (`fct.txt`)
Each line should contain at least 8 columns, for example:

```
0b000001 0b000101 10000 100 131072 10 53542 54290
```

- **Column 0**: Source node ID (e.g., `0b000001`)
- **Column 1**: Destination node ID (e.g., `0b000101`)
- **Column 4**: Start time (in ns)
- **Column 5**: End time (in ns)
- **Last 2 columns**: TX bytes, RX bytes

## Output File Format (`matrix.txt`)
- Each row: total TX bytes sent from node i to node j (space-separated)
- Last line: total simulation time in milliseconds (e.g., `0.620 ms`)

## Example

```
0 749588 0 0 0 0 0 0
0 0 749588 0 0 0 0 0
...
0.620 ms
```

## Notes
- The script only uses TX bytes for the matrix.
- The total time is calculated as the difference between the earliest start time and the latest end time across all flows, converted to milliseconds. 