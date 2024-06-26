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
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
```

### Ignore packages

In some cases, you may want to ignore certain packages (since they cannot be installed or for any other reason):

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    ignore: broken_package
```

### Select only a subset of packages

Alternatively, you may run only a whitelisted subset of the dependents:

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    whitelist: >-
        package1
        package2
```

### Include additional packages

Some packages you may want to test against may depend on your package only
optionally and will not show up in the dependency tree. Those can be
explicitly included in the workflow and tested with others using the
`include` input.

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    include: >-
        package1
        package2
```

### Specify environment

You can set up the environment with dependencies required to build
your package by passing the conda environment file:

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    env: environment.yml
```

Alternatively, (or additionally) you can specify packages to be installed
in the environment with conda in the `install` input:

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    install: package1 package2
```

Or with pip using `install_pip` input:

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    install_pip: package1 package2
```


The default Python version installed in the environment is 3.11. You can
override that either in your environment file or using `python_version`.

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    python_version: 3.9
```

If you need to run a specific command in the docker container prior the
installation of the packages, you can specify it in the `run` input. The
command will be run before setting up the conda environment. For example,
to install GCC you can do:

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    run: apt-get update && apt install build-essential -y
```

### Customize installation command

By default, the action attempts to install the package using
`pip install .`. However, you can specify your own command:

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    installation_command: pip install --no-deps --no-build-isolation .
```

### Fail or pass on test failure

The action returns an exit code 1 (failure) if there is at least one
failed test. You can avoid it by setting `fail_on_failure` to `false`.

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    fail_on_failure: false
```

### XFail package tests

You can allow some packages to fail without failing the whole action.

```yml
- uses: scientific-python/reverse-dependency-testing@main
with:
    package_name: mypackage
    xfail: package1 package2
```


## How to ensure that tests are packaged?

The easiest way to ensure that the tests are packaged is to store them
in the package folder (usually called `package_name` or `src/package_name`).

```
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

## How does the Action work?

The principle is simple:

1. Use `micromamba repoquery whoneeds mypackage -c conda-forge` to fetch the direct dependents of `mypackage` based on the `conda-forge` index.
2. De-duplicate the list to retrieve unique package names.
3. Create an environment with all the packages and install `mypackage` from main.
4. Loop over the package names and run `pytest --pyargs packagename` for each.
