#!/usr/bin/env python3
"""Flags translations that are too close to existing published translations.

The reference translations are used ONLY for comparison and must never be copied into
this repository. Point the script at a local folder containing verse.json and
translation.json in the github.com/gita/gita format (or any reference set converted
to it).

A verse is flagged when it shares a run of >= 6 consecutive words with a reference
translation, or when the overall word-sequence similarity is above 0.5. Flagged
verses must be rewritten from the Sanskrit before they can be marked reviewed.

Usage: python3 tool/check_similarity.py path/to/reference_dir [content/translations/ch01.json ...]
Exit code 1 when anything is flagged.
"""
import difflib
import json
import pathlib
import re
import sys

RUN = 6
RATIO = 0.5
ROOT = pathlib.Path(__file__).resolve().parent.parent
FIELDS = {"english": "english", "hindi": "hindi"}


def words(text):
    text = re.sub(r"।।\s*\d+\.\d+\s*।।", " ", text or "")
    return re.findall(r"[\wऀ-ॿ']+", text.lower())


def runs(ws):
    return {tuple(ws[i:i + RUN]) for i in range(len(ws) - RUN + 1)}


def main():
    ref_dir = pathlib.Path(sys.argv[1])
    files = [pathlib.Path(p) for p in sys.argv[2:]] or sorted((ROOT / "content" / "translations").glob("ch*.json"))
    verses = json.loads((ref_dir / "verse.json").read_text(encoding="utf-8"))
    refs = json.loads((ref_dir / "translation.json").read_text(encoding="utf-8"))
    verse_id = {(v["chapter_number"], v["verse_number"]): v["id"] for v in verses}
    by_verse = {}
    for r in refs:
        by_verse.setdefault((r["verse_id"], r["lang"]), []).append(r)

    flagged = 0
    for path in files:
        data = json.loads(path.read_text(encoding="utf-8"))
        for v in data["verses"]:
            vid = verse_id[(data["chapter"], v["number"])]
            for field, lang in FIELDS.items():
                mine = words(v.get(field))
                for ref in by_verse.get((vid, lang), []):
                    theirs = words(ref["description"])
                    shared = runs(mine) & runs(theirs)
                    ratio = difflib.SequenceMatcher(None, mine, theirs).ratio()
                    if shared or ratio > RATIO:
                        flagged += 1
                        sample = " ".join(next(iter(shared))) if shared else ""
                        print(f"FLAG {data['chapter']}.{v['number']} {field} ~ {ref['authorName']}: "
                              f"similarity {ratio:.2f} {('shared: ' + sample) if sample else ''}")
    print(f"{flagged} flagged")
    sys.exit(1 if flagged else 0)


if __name__ == "__main__":
    main()
