"""Book Hub worker CLI entry point.

Usage:
    python -m bookhub run --job <id>   process a single job (debug)
    python -m bookhub poll             poll for pending jobs (default)

Pipeline stages land in later phases; for now this is a scaffold.
"""

import argparse
import os
import sys
import time

from bookhub import __version__


def _poll(interval: int) -> int:
    # Scaffold: placeholder loop that mirrors the future DB poller shape.
    # Job claiming lands in Phase 4.
    print("bookhub worker scaffold: polling loop active (no-op)")
    while True:
        time.sleep(interval)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="bookhub", description=__doc__)
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    sub = parser.add_subparsers(dest="command")
    sub.add_parser("run", help="process a single job (--job)")
    poll = sub.add_parser("poll", help="poll for pending jobs")
    poll.add_argument(
        "--interval",
        type=int,
        default=int(os.environ.get("WORKER_POLL_INTERVAL", "5")),
        help="poll interval in seconds",
    )
    args = parser.parse_args(argv)

    if args.command is None:
        parser.print_help()
        return 0

    if args.command == "poll":
        return _poll(args.interval)

    print("bookhub worker scaffold: pipeline not implemented yet")
    return 0


if __name__ == "__main__":
    sys.exit(main())