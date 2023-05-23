import os

with open("whoneeds.txt", "r") as f:
    lines = f.readlines()

# Create an empty set to store the values
values = set()

use = False
# Loop through each line except the first two and the last one
for line in lines[:-1]:
    if use:
        # Split the line by whitespace characters
        package = line.split()[0]
        if package not in os.getenv("INPUT_EXCLUDE"):
            values.add("  - " + package + "\n")
    if line.startswith("────────────"):
        use = True

yml = [
    "name: base\n",
    "channels:\n",
    "  - conda-forge\n",
    "dependencies:\n",
]
yml.extend(values)

print("Dependency tree analysis created a following environment specification:\n")
print(*yml)

with open("reverse.yaml", "w") as f:
    f.writelines(yml)

print("YAML saved to reverse.yaml\n")
