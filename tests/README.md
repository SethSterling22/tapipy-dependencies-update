# Running Tests

To run all unit tests:

1.  `cd` into the root directory of the tapipy project.
2.  Activate the virtual Python environment. You can use either of the two commands:
    * `poetry env activate` (modern option, activates the environment in the current shell).
    * `poetry shell` (legacy option, opens a new shell).
        - You must install shell plugin `poetry self add poetry-plugin-shell`.
3.  Install the requirements by running `poetry install`.
4.  `cd` into the `tapipy/tests` directory.
5.  Run `chmod +x run.sh`.
6.  Run the `./run.sh` script.
