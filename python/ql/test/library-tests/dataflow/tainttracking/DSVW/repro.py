#!/usr/bin/env python3

import re
import urllib.parse
import sys

def alt():
    query = sys.argv[1] # source

    for match in re.finditer(
        r"((\A|[?&])(?P<parameter>[\w\[\]]+)=)([^&]+)", query
    ):
        params = dict(
                match.group("parameter"),
                urllib.parse.unquote(
                    ",".join(
                        re.findall(
                            r"(?:\A|[?&])%s=([^&]+)" % match.group("parameter"), query  # taint doesn't even *reach* here
                        )
                    )
                ),
            )

        print(params)   # sink

def main():
    """Take params from arg 1, parse, print out."""

    query = sys.argv[1] # source

    params = dict(
            (
                match.group("parameter"),
                urllib.parse.unquote(
                    ",".join(
                        re.findall(
                            r"(?:\A|[?&])%s=([^&]+)" % match.group("parameter"), query  # taint doesn't even *reach* here
                        )
                    )
                ),
            )
            for match in re.finditer(
                r"((\A|[?&])(?P<parameter>[\w\[\]]+)=)([^&]+)", query   # no taint *from* here
            )
        )

    print(params)   # sink


if __name__ == "__main__":
    main()