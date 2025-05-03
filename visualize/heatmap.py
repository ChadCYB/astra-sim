import sys
import os
import numpy as np
import matplotlib.pyplot as plt

def read_matrix(matrix_path):
    """
    Reads the matrix from matrix.txt, ignoring the last line (which contains the total time).
    Returns a 2D numpy array.
    """
    matrix = []
    with open(matrix_path, 'r') as f:
        lines = f.readlines()
        # Find the expected number of columns from the first non-empty line
        num_cols = None
        for line in lines[:-1]:  # Ignore the last line (ms)
            if not line.strip():
                continue
            row = [int(x) for x in line.strip().split()]
            if num_cols is None:
                num_cols = len(row)
            if len(row) == num_cols:
                matrix.append(row)
    if not matrix or any(len(row) != num_cols for row in matrix):
        raise ValueError('Matrix is empty or not rectangular.')
    return np.array(matrix)

def plot_heatmap(matrix, output_path):
    """
    Plots and saves a heatmap from the given matrix, displaying values in MB.
    Zero values are shown as white. Uses a blue color map similar to the provided image.
    """
    matrix_mb = matrix / (1024 * 1024)  # Convert bytes to MB
    plt.figure(figsize=(6, 6))
    cmap = plt.cm.YlGnBu.copy()
    im = plt.imshow(matrix_mb, cmap=cmap, interpolation='nearest', vmin=0.0001)
    plt.colorbar(im, label='Traffic (MB)')
    plt.title('Traffic Matrix Heatmap (MB)')
    plt.xlabel('Destination Node')
    plt.ylabel('Source Node')
    plt.tight_layout()
    plt.savefig(output_path)
    plt.close()

def main():
    if len(sys.argv) != 2:
        print('Usage: python heatmap.py <matrix.txt>')
        sys.exit(1)
    matrix_path = sys.argv[1]
    matrix = read_matrix(matrix_path)
    # Save heatmap.png in the same directory as matrix.txt
    output_dir = os.path.dirname(os.path.abspath(matrix_path))
    output_path = os.path.join(output_dir, 'heatmap.png')
    plot_heatmap(matrix, output_path)

if __name__ == '__main__':
    main() 