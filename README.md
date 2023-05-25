# Reverse dependency testing

**NOTE: This is an alpha version, proceed with caution.**

This GitHub Action allows you to query conda-forge dependency tree and run
tests included in packages that depend on your package against your development version.

The workflow is able to run tests only if the downstream packages do
package them, including all the necessary files. Otherwise, it will skip
the package with no collected tests or report a failure.

## Usage

For the simple packages, the setup is simple, you just need to pass a
`package_name` used for the dependency tree query:

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
```

In some cases, you may want to ignore certain packages (since they cannot be installed or for any other reason):

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    ignore: broken_package
```

Alternatively, you may run only a whitelisted subset of the dependents:

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    whitelist: >-
        package1
        package2
```

Some packages you may want to test against may depend on your package only
optionally and will not show up in the dependency tree. Those can be
explicitly included in the workflow and tested with others using the
`include` input.

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    include: >-
        package1
        package2
```

You can set up the environment with dependencies required to build
your package by passing the conda environment file:

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    env: environment.yml
```

Alternatively, (or additionally) you can specify packages to be installed
in the environment in the `install` input:

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    install: package1 package2
```

By default, the action attempts to install the package using
`pip install .`. However, you can specify your own command:

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    installation_command: pip install --no-deps --no-build-isolation .
```

The action returns an exit code 1 (failure) if there is at least one
failed test. You can avoid it by setting `fail_on_failure` to `false`.

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    fail_on_failure: false
```

If you need to run a specific command in the docker container prior the
installation of the packages, you can specify it in the `run` input. The
command will be run before setting up the conda environment. For example,
to install GCC you can do:

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    run: apt-get update && apt install build-essential -y
```

The default Python version installed in the environment is 3.11. You can
override that either in your environment file or using `python_version`.

```yml
- uses: martinfleis/reverse-dependency-testing@main
with:
    package_name: mypackage
    python_version: 3.9
```

## How to ensure that tests are packaged?

The easiest way to ensure that the tests are packaged is to store them
in the package folder (usually called `package_name` or `src/package_name`).

```txt
mypackage
├── pyproject.toml
|   README.md
|   LICENCE
└── mypackage
    ├── __init__.py
    ├── my_module.py
    └──tests
        └──test_my_module.py
```

You can verify that the tests can be found by running

```sh
pytest --pyargs mypackage
```

Packaging of tests is useful not only for this action but also to allow users
to verify that your package is correctly installed in their environment.
