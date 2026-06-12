import sys

def min_max_mean(numbers):
    return min(numbers), max(numbers), sum(numbers) / len(numbers)


if __name__ == "__main__":
    numbers = [float(x) for x in sys.argv[1:]]
    mn, mx, mean = min_max_mean(numbers)
    print(f"min: {mn}")
    print(f"max: {mx}")
    print(f"mean: {mean}")