#!/usr/bin/env python3
"""Checks the short quote lines in content/emotions.json against reference translations.

Same rule as check_similarity.py: a line is flagged when it shares a run of 6 or more
consecutive words with a reference translation of the same verse.

Usage: python3 tool/check_quote_similarity.py path/to/reference_dir
Exit code 1 when anything is flagged.
"""
import json
import pathlib
import sys

import check_similarity as cs

ROOT = pathlib.Path(__file__).resolve().parent.parent


def main():
    ref_dir = pathlib.Path(sys.argv[1])
    verses = json.loads((ref_dir / "verse.json").read_text(encoding="utf-8"))
    refs = json.loads((ref_dir / "translation.json").read_text(encoding="utf-8"))
    verse_id = {(v["chapter_number"], v["verse_number"]): v["id"] for v in verses}
    by_verse = {}
    for r in refs:
        by_verse.setdefault((r["verse_id"], r["lang"]), []).append(r)

    flagged = 0
    emotions = json.loads((ROOT / "content" / "emotions.json").read_text(encoding="utf-8"))
    for emotion in emotions["emotions"]:
        for q in emotion["quotes"]:
            chapter, number = map(int, q["verse"].split("."))
            for field, lang in cs.FIELDS.items():
                mine = cs.runs(cs.words(q[field]))
                for ref in by_verse.get((verse_id[(chapter, number)], lang), []):
                    shared = mine & cs.runs(cs.words(ref["description"]))
                    if shared:
                        flagged += 1
                        print(f"FLAG {emotion['id']} {q['verse']} {field}: '{' '.join(next(iter(shared)))}'")
    print(f"{flagged} flagged")
    sys.exit(1 if flagged else 0)


if __name__ == "__main__":
    main()
