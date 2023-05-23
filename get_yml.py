with open("whoneeds.txt", "r") as f:
    lines = f.readlines()

# Create an empty set to store the values
values = set()

use = False
# Loop through each line except the first two and the last one
for line in lines[:-1]:
    if use:
        # Split the line by whitespace characters
        columns = line.split()
        # Add the first column value to the set
        values.add("  - " + columns[0] + "\n")
    if line.startswith("────────────"):
        use = True

yml = [
    "name: reverse-test\n",
    "channels:\n",
    "  - conda-forge\n",
    "dependencies:\n",
]
yml.extend(values)

print("Dependency tree analysis created a following environment specification:\n")
print(*yml)

with open("reverse.yml", "w") as f:
    f.writelines(yml)

print("YML saved to reverse.yml")
