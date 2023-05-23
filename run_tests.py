import subprocess

with open("packages.txt", "r") as f:
    packages = f.readlines()

for package in packages:
    subprocess.run(["pytest", "--pyargs", package])
