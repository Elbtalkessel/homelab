#!/usr/bin/env python
import fileinput
import typing


class LogLine(typing.NamedTuple):
    time: str
    duration: str
    duration_ns: str
    level: str | None = None


def parser(line: str):
    line = line.strip()


def main():
    for line in fileinput.input():
        ...
