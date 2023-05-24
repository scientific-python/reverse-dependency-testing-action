import os

with open("whoneeds.txt", "r") as f:
    lines = f.readlines()

# Create an empty set to store the values
packages = set()

excluded = os.getenv("INPUT_EXCLUDED").split(",")

use = False
# Loop through each line except the first two and the last one
for line in lines[:-1]:
    if use:
        # Split the line by whitespace characters
        package = line.split()[0]
        if package not in excluded:
            packages.add(package)
    if line.startswith("────────────"):
        use = True

yml = [
    "name: base\n",
    "channels:\n",
    "  - conda-forge\n",
    "dependencies:\n",
    "  - pytest\n",
]
yml.extend(["  - " + package + "\n" for package in packages])

print("Dependency tree analysis created a following environment specification:\n")
print(*yml)

with open("reverse.yaml", "w") as f:
    f.writelines(yml)

print("YAML saved to reverse.yaml\n")

with open("packages.txt", "w") as f:
    f.writelines(sorted([p + "\n" for p in packages]))
