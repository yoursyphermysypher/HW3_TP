import sys

def convert(celsius):
    fahrenheit = celsius * 9 / 5 + 32
    kelvin = celsius + 273.15
    return fahrenheit, kelvin

if __name__ == "__main__":
    celsius = float(sys.argv[1])

    fahrenheit, kelvin = convert(celsius)

    print(f"fahrenheit: {fahrenheit}")
    print(f"kelvin: {kelvin}")