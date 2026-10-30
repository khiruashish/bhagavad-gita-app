#!/usr/bin/env python3
"""Builds assets/content/gita.json, the only content file the app loads.

Inputs (all in content/):
  sanskrit.json          Sanskrit + generated IAST for all 701 verses (public domain)
  chapters.json          chapter titles and summaries (original to this project)
  learn.json             speaker labels, "Start here" sections, glossary (original)
  quotes.json            verses picked for the Quotes tab, with short topics (original)
  emotions.json          Feelings tab: emotions with short quote lines and their verses (original)
  reflections.json       reflection questions for the daily verse, three per chapter (original)
  translations/chNN.json translations and simple meanings (original to this project)

Usage:
  python3 tool/build_content.py                 # include draft translations
  python3 tool/build_content.py --reviewed-only # store release: reviewed translations only
  python3 tool/build_content.py --check         # validate only, write nothing

Exits non-zero on any validation error.
"""
import argparse
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CONTENT = ROOT / "content"
OUT = ROOT / "assets" / "content" / "gita.json"

REQUIRED = ("english", "hindi", "simpleEnglish", "simpleHindi")
OPTIONAL = ("wordMeanings", "notes")
STATUSES = {"draft", "reviewed"}
BANNED = re.compile(
    r"\b(delve|journey|tapestry|profound|embark|realm|navigate|essence|timeless|ultimately|truly)\b",
    re.IGNORECASE,
)
CHAPTER_VERSES = [47, 72, 43, 42, 29, 47, 30, 28, 34, 42, 55, 20, 35, 27, 20, 24, 28, 78]


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def build(reviewed_only):
    errors = []
    sanskrit = load(CONTENT / "sanskrit.json")["verses"]
    chapters = load(CONTENT / "chapters.json")["chapters"]
    learn = load(CONTENT / "learn.json")
    speakers = learn["speakers"]

    if [c["number"] for c in chapters] != list(range(1, 19)):
        errors.append("chapters.json must list chapters 1..18 in order")
    for c in chapters:
        for k in ("sanskrit", "english", "hindi", "summaryEnglish", "summaryHindi"):
            if not c.get(k, "").strip():
                errors.append(f"chapter {c['number']}: missing {k}")

    counts = [sum(1 for v in sanskrit if v["chapter"] == n) for n in range(1, 19)]
    if counts != CHAPTER_VERSES:
        errors.append(f"sanskrit.json verse counts {counts} != expected {CHAPTER_VERSES}")

    translations = {}
    for path in sorted((CONTENT / "translations").glob("ch*.json")):
        data = load(path)
        ch = data["chapter"]
        for t in data["verses"]:
            key = (ch, t["number"])
            where = f"{path.name} {ch}.{t['number']}"
            if key in translations:
                errors.append(f"{where}: duplicate verse")
            if not 1 <= t["number"] <= CHAPTER_VERSES[ch - 1]:
                errors.append(f"{where}: verse number out of range")
            if t.get("status") not in STATUSES:
                errors.append(f"{where}: status must be one of {sorted(STATUSES)}")
            for k in REQUIRED:
                if not t.get(k, "").strip():
                    errors.append(f"{where}: missing {k}")
            unknown = set(t) - set(REQUIRED) - set(OPTIONAL) - {"number", "status", "reviewedBy"}
            if unknown:
                errors.append(f"{where}: unknown fields {sorted(unknown)}")
            if t.get("status") == "reviewed" and not t.get("reviewedBy", "").strip():
                errors.append(f"{where}: reviewed verses must name reviewedBy")
            for k in ("english", "simpleEnglish"):
                m = BANNED.search(t.get(k, ""))
                if m:
                    errors.append(f"{where}: banned word '{m.group(0)}' in {k}")
            translations[key] = t

    verses = []
    for s in sanskrit:
        item = {"chapter": s["chapter"], "verse": s["verse"], "sanskrit": s["sanskrit"], "iast": s["iast"]}
        if s["speaker"]:
            label = speakers.get(s["speaker"])
            if not label:
                errors.append(f"{s['chapter']}.{s['verse']}: no label for speaker {s['speaker']!r}")
            else:
                item["speaker"] = {"sanskrit": s["speaker"], "iast": s["speakerIast"], **label}
        t = translations.get((s["chapter"], s["verse"]))
        if t and (t["status"] == "reviewed" or not reviewed_only):
            for k in REQUIRED + OPTIONAL:
                if t.get(k):
                    item[k] = t[k]
            item["status"] = t["status"]
        verses.append(item)

    by_id = {f"{v['chapter']}.{v['verse']}": v for v in verses}

    def standalone(where, verse_id):
        """The verse exists and its translation reads as a complete sentence."""
        v = by_id.get(verse_id)
        if v is None:
            errors.append(f"{where}: no such verse {verse_id}")
            return None
        text = translations.get((v["chapter"], v["verse"]), {}).get("english", "").strip()
        if text and (text[0].islower() or text[-1] in ",;:"):
            errors.append(f"{where}: {verse_id} is not a complete sentence on its own")
        return v

    def check_text(where, item, fields):
        for k in fields:
            if not item.get(k, "").strip():
                errors.append(f"{where}: missing {k}")
            m = BANNED.search(item.get(k, "")) if k.lower().endswith("english") else None
            if m:
                errors.append(f"{where}: banned word '{m.group(0)}' in {k}")

    quotes, last = [], (0, 0)
    for q in load(CONTENT / "quotes.json")["quotes"]:
        where = f"quotes.json {q.get('id')}"
        v = standalone(where, q.get("id"))
        if v is None:
            continue
        if (v["chapter"], v["verse"]) <= last:
            errors.append(f"{where}: quotes must be in reading order without repeats")
        last = (v["chapter"], v["verse"])
        check_text(where, q, ("topicEnglish", "topicHindi"))
        # A store build leaves out quotes whose translation is not reviewed yet.
        if "english" in v:
            quotes.append(q)

    emotions, seen = [], set()
    for emo in load(CONTENT / "emotions.json")["emotions"]:
        where = f"emotions.json {emo.get('id')}"
        if emo.get("id") in seen:
            errors.append(f"{where}: duplicate id")
        seen.add(emo.get("id"))
        if emo.get("group") not in ("hard", "grow"):
            errors.append(f"{where}: group must be 'hard' or 'grow'")
        check_text(where, emo, ("emoji", "titleEnglish", "titleHindi", "introEnglish", "introHindi"))
        quotes_in = emo.get("quotes", [])
        if not 3 <= len(quotes_in) <= 6:
            errors.append(f"{where}: list 3 to 6 quotes")
        if len({q.get("verse") for q in quotes_in}) != len(quotes_in):
            errors.append(f"{where}: repeated verse")
        kept = []
        for q in quotes_in:
            qwhere = f"{where} {q.get('verse')}"
            v = by_id.get(q.get("verse"))
            if v is None:
                errors.append(f"{qwhere}: no such verse")
                continue
            check_text(qwhere, q, ("english", "hindi"))
            for k in ("english", "hindi"):
                if len(q.get(k, "")) > 160:
                    errors.append(f"{qwhere}: {k} quote longer than 160 characters")
            # A store build keeps only quotes whose verse translation is reviewed.
            if "english" in v:
                kept.append(q)
        # ...and shows an emotion only once at least two of its quotes remain.
        if len(kept) >= 2:
            emotions.append({**emo, "quotes": kept})

    reflections = load(CONTENT / "reflections.json")["chapters"]
    if [r.get("chapter") for r in reflections] != list(range(1, 19)):
        errors.append("reflections.json must list chapters 1..18 in order")
    for r in reflections:
        if not r.get("questions"):
            errors.append(f"reflections.json chapter {r.get('chapter')}: no questions")
        for i, q in enumerate(r.get("questions", [])):
            check_text(f"reflections.json {r.get('chapter')}.{i + 1}", q, ("english", "hindi"))

    out = {
        "format": 1,
        "chapters": [{**c, "verseCount": CHAPTER_VERSES[c["number"] - 1]} for c in chapters],
        "verses": verses,
        "learn": {"sections": learn["sections"], "glossary": learn["glossary"]},
        "quotes": quotes,
        "emotions": emotions,
        "reflections": {str(r["chapter"]): r["questions"] for r in reflections},
    }
    return out, errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--reviewed-only", action="store_true")
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    out, errors = build(args.reviewed_only)
    for e in errors:
        print("ERROR", e, file=sys.stderr)
    if errors:
        sys.exit(1)
    translated = sum(1 for v in out["verses"] if "english" in v)
    reviewed = sum(1 for v in out["verses"] if v.get("status") == "reviewed")
    print(f"ok: {len(out['verses'])} verses, {translated} translated, {reviewed} reviewed")
    if not args.check:
        OUT.parent.mkdir(parents=True, exist_ok=True)
        OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
        print(f"wrote {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
