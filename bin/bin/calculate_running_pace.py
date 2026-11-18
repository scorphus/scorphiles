#!/usr/bin/env python3
"""Calculate run pace.

Input: distance (in km), time (as a string in the format "HH:MM:SS")
Output: pace (a string in the format "MM:SS")
"""


def calculate_run_pace(distance, time):
    hours, minutes, seconds = map(int, time.split(':'))
    total_seconds = hours * 3600 + minutes * 60 + seconds
    pace_seconds = total_seconds / distance
    pace_minutes = int(pace_seconds // 60)
    pace_remaining_seconds = int(pace_seconds % 60)
    return f"{pace_minutes:02}:{pace_remaining_seconds:02}"


def main():
    distance = float(input("Enter distance (in km): "))
    time = input("Enter time (as a string in the format 'HH:MM:SS'): ")
    pace = calculate_run_pace(distance, time)
    print(f"Your pace is {pace} per kilometer.")


if __name__ == "__main__":
    main()
