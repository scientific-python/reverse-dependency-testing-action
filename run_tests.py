import os
import subprocess

packages = os.environ["TEST_PACKAGES"].split(",")

for package in packages:
    subprocess.run(["pytest", "--pyargs", package])
