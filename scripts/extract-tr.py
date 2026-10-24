#!/usr/bin/env python3
"""Extracts @tr("...") strings into i18n/lunadash.pot and merges them into every i18n/*.po.

Existing translations are kept; new strings get an empty msgstr, removed ones are dropped.
Usage: scripts/extract-tr.py
"""
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent.parent
PATTERN = re.compile(r'@tr\("((?:[^"\\]|\\.)*)"')


def quote(text: str) -> str:
    return '"' + text + '"'


def extract() -> dict[str, list[str]]:
    found: dict[str, list[str]] = {}
    for path in sorted(ROOT.rglob("*.slint")):
        rel = path.relative_to(ROOT)
        for number, line in enumerate(path.read_text().splitlines(), 1):
            for match in PATTERN.finditer(line):
                found.setdefault(match.group(1), []).append(f"{rel}:{number}")
    return found


def read_po(path: pathlib.Path) -> dict[str, str]:
    entries, msgid, field = {}, None, None
    for line in path.read_text().splitlines():
        if line.startswith("msgid "):
            msgid, field = line[7:-1], "id"
        elif line.startswith("msgstr "):
            entries[msgid] = line[8:-1]
            field = "str"
        elif line.startswith('"') and msgid is not None:
            if field == "id":
                msgid += line[1:-1]
            else:
                entries[msgid] += line[1:-1]
    return entries


def write(path: pathlib.Path, strings: dict[str, list[str]], header: str, translated: dict[str, str]):
    out = [header]
    for msgid, places in strings.items():
        out.append("#: " + " ".join(places[:3]))
        if "{}" in msgid:
            out.append("#, c-format")
        out.append("msgid " + quote(msgid))
        out.append("msgstr " + quote(translated.get(msgid, "")))
        out.append("")
    path.write_text("\n".join(out))


def header(language: str) -> str:
    return (
        'msgid ""\nmsgstr ""\n'
        '"Project-Id-Version: LunaDash Shell\\n"\n'
        f'"Language: {language}\\n"\n'
        '"MIME-Version: 1.0\\n"\n'
        '"Content-Type: text/plain; charset=UTF-8\\n"\n'
        '"Content-Transfer-Encoding: 8bit\\n"\n'
    )


def main():
    strings = extract()
    i18n = ROOT / "i18n"
    i18n.mkdir(exist_ok=True)
    write(i18n / "lunadash.pot", strings, header(""), {})
    for po in sorted(i18n.glob("*.po")):
        old = read_po(po)
        write(po, strings, header(po.stem), old)
        missing = [s for s in strings if not old.get(s)]
        print(f"{po.name}: {len(strings) - len(missing)}/{len(strings)} translated")
    print(f"{len(strings)} strings")


if __name__ == "__main__":
    main()
