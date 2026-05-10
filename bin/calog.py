#!/usr/bin/env python
import fileinput
import typing


class LogLine(typing.NamedTuple):
    time: str
    level: str
    duration: str
    duration_ns: typing.Annotated[int, {"field": "duration-ns"}]
    fields_time: typing.Annotated[str, {"field": "fields.time"}]
    method: str
    name: str
    nonce: str
    path: str
    portocol: str
    referer: str
    remote_address: typing.Annotated[str, {"field": "remote-address"}]
    request_id: typing.Annotated[str, {"field": "request-id"}]
    size: int
    status: int
    user_agent: typing.Annotated[str, {"field": "user-agent"}]
    user_id: typing.Annotated[str, {"field": "user-id"}]


class ResponseLogLine(LogLine):
    response: dict


def parser(line: str):
    line = line.strip()


def main():
    for line in fileinput.input():
        ...
