import os

# open the output of repoquery
with open("whoneeds.txt", "r") as f:
    lines = f.readlines()

# Create an empty set to store the values
packages = set()

# track if we have whitelist
whitelist = False

# get blacklisted packages
excluded = os.getenv("INPUT_EXCLUDE").split(",")

# get whitelisted packages
included = os.getenv("INPUT_INCLUDE")
if included != "":
    included.split(",")
    whitelist = True

# track if we can parse the line
use = False

# Loop through each line except the first two and the last one
for line in lines[:-1]:
    if use:
        # Split the line by whitespace characters
        package = line.split()[0]
        if whitelist:
            if package in included:
                packages.add(package)
        else:
            if package not in excluded:
                packages.add(package)

    # start collecting packages after this line in the whoneeds.txt
    if line.startswith("────────────"):
        use = True

# cast to list
packages = list(packages)

# add additional packages to be tested
additional = os.getenv("INPUT_ADDITIONAL")
if additional != "":
    packages.extend(additional.split(","))

yml = [
    "name: base\n",
    "channels:\n",
    "  - conda-forge\n",
    "dependencies:\n",
    "  - pytest\n",
    "  - pytest-xdist\n",
]
yml.extend(["  - " + package + "\n" for package in packages])

# add additional packages to the env
install = os.getenv("INPUT_INSTALL")
if install != "":
    yml.extend(["  - " + package + "\n" for package in install.split(",")])

print("Dependency tree analysis created a following environment specification:\n")
print(*yml)

with open("reverse.yaml", "w") as f:
    f.writelines(yml)

print("YAML saved to reverse.yaml\n")

with open("packages.txt", "w") as f:
    f.writelines(sorted([p + "\n" for p in packages]))
