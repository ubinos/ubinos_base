import serial
import time
import typer

import ipdb

__version__ = "1.0.0"


def main(
    version: bool = typer.Option(False, "-v", "--version", help="Show version."),
    debug: bool = typer.Option(False, "-d", "--debug", help="Enable debug mode."),
):
    if version:
        print(f"Hello World v{__version__}")
        return

    if debug:
        print("Debug mode enabled — entering ipdb before main()")
        ipdb.set_trace()

    count = 0
    while True:
        count += 1
        print("%08d : Hello World!" % (count))
        time.sleep(1)

if __name__ == "__main__":
    typer.run(main)
