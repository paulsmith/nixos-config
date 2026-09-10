#!/usr/bin/env python3
"""Inline the rendered D2 diagrams into the handbook as data URIs.

Produces a single self-contained index.html with no external asset requests.
"""
import base64, pathlib, sys

HERE = pathlib.Path(__file__).parent
DIAGRAMS = HERE / "diagrams"

TOKENS = {
    "__HOSTS_LIGHT__": "hosts.svg",
    "__HOSTS_DARK__": "hosts-dark.svg",
    "__ARCH_LIGHT__": "architecture.svg",
    "__ARCH_DARK__": "architecture-dark.svg",
    "__TIERS_LIGHT__": "tiers.svg",
    "__TIERS_DARK__": "tiers-dark.svg",
    "__ACT_LIGHT__": "activation.svg",
    "__ACT_DARK__": "activation-dark.svg",
}

def data_uri(name):
    raw = (DIAGRAMS / name).read_bytes()
    return "data:image/svg+xml;base64," + base64.b64encode(raw).decode("ascii")

def main():
    html = (HERE / "index.src.html").read_text()
    for token, svg in TOKENS.items():
        if token not in html:
            sys.exit(f"token {token} missing from index.src.html")
        html = html.replace(token, data_uri(svg))
    out = HERE / "index.html"
    out.write_text(html)
    print(f"wrote {out} ({len(html) // 1024} KB)")

if __name__ == "__main__":
    main()
