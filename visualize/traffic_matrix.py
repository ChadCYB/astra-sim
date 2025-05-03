import sys
import os

def parse_node_id(bin_str):
    # The node id is after '0b', treat as decimal (not binary)
    if bin_str.startswith('0b'):
        return int(bin_str[2:])
    return int(bin_str)

def build_traffic_matrix(fct_path, output_path):
    node_ids = set()
    flows = []
    min_start_time = None
    max_end_time = None
    with open(fct_path, 'r') as f:
        for line in f:
            parts = line.strip().split()
            if len(parts) < 8:
                continue
            src = parse_node_id(parts[0])
            dst = parse_node_id(parts[1])
            # TX and RX are the last two columns
            tx_bytes = int(parts[-2])
            rx_bytes = int(parts[-1])
            # Start and end times are columns 4 and 5 (0-based)
            start_time = int(parts[4])
            end_time = int(parts[5])
            if min_start_time is None or start_time < min_start_time:
                min_start_time = start_time
            if max_end_time is None or end_time > max_end_time:
                max_end_time = end_time
            node_ids.add(src)
            node_ids.add(dst)
            flows.append((src, dst, tx_bytes))
    node_ids = sorted(node_ids)
    node_id_to_idx = {nid: idx for idx, nid in enumerate(node_ids)}
    n = len(node_ids)
    matrix = [[0 for _ in range(n)] for _ in range(n)]
    for src, dst, tx_bytes in flows:
        i = node_id_to_idx[src]
        j = node_id_to_idx[dst]
        matrix[i][j] += tx_bytes
    total_time_ns = max_end_time - min_start_time if min_start_time is not None and max_end_time is not None else 0
    total_time_ms = total_time_ns / 1_000_000
    with open(output_path, 'w') as f:
        for row in matrix:
            f.write(' '.join(str(x) for x in row) + '\n')
        f.write(f'{total_time_ms:.3f} ms\n')

def main():
    if len(sys.argv) != 3:
        print('Usage: python traffic_matrix.py <fct.txt> <matrix.txt>')
        sys.exit(1)
    fct_path = sys.argv[1]
    output_path = sys.argv[2]
    build_traffic_matrix(fct_path, output_path)

if __name__ == '__main__':
    main() 