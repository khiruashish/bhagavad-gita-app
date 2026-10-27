#!/usr/bin/env python3
"""Imports the Sanskrit text of the Bhagavad Gita into content/sanskrit.json.

Source: verse.json from https://github.com/gita/gita (released under The Unlicense).
Only the Sanskrit (Devanagari) field is used; the Sanskrit text itself is ancient and in
the public domain. No translation, transliteration or commentary is taken from the
source. Transliteration is generated locally by tool/iast.py.

Usage: python3 tool/import_sanskrit.py path/to/verse.json
"""
import json
import pathlib
import re
import sys

from iast import to_iast

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "content" / "sanskrit.json"

# Source files carry some vowel signs typed before the consonant they belong to
# (e.g. "निश्िचतं" for "निश्चितं"). Move the sign after the next consonant.
MISPLACED_I = re.compile("्ि([क-ह])")

# Vowel sign typed before a conjunct instead of after it (e.g. "तत्ति्रविधं" for "तत्त्रिविधं").
MISPLACED_I_CONJUNCT = re.compile("([क-ह])ि्([क-ह])")

# Known typos in the digital source, fixed against standard printed editions.
# Each fix must apply exactly once (checked at import time).
TYPO_FIXES = {
    (1, 34): [("श्चशुराः", "श्वशुराः")],
    (2, 31): [("युद्धाछ्रेयो", "युद्धाच्छ्रेयो")],
    (2, 33): [("चैत्त्वमिमं", "चेत्त्वमिमं")],
    (4, 29): [("जुह्वति प्राण प्राणे", "जुह्वति प्राणं प्राणे")],
    (9, 21): [("एव त्रयीधर्म", "एवं त्रयीधर्म")],
    (11, 21): [("सुरसङ्घाः विशन्ति", "सुरसङ्घा विशन्ति")],
    (11, 51): [("तवसौम्यं", "तव सौम्यं")],
    (11, 54): [("दृष्टुं", "द्रष्टुं")],
    (12, 1): [("येचाप्यक्षर", "ये चाप्यक्षर")],
    (12, 19): [("येनकेनचित्", "येन केनचित्")],
    (13, 12): [("यदतोन्यथा", "यदतोऽन्यथा")],
    (13, 24): [("गुणैःसह", "गुणैः सह")],
    (15, 4): [("परिमार्गितव्य यस्मिन्", "परिमार्गितव्यं यस्मिन्")],
    (16, 20): [("असुरीं योनिम", "आसुरीं योनिम")],
    (17, 23): [("तत्सदिति", "ॐ तत्सदिति")],
    (17, 25): [("मोक्षकाङ्क्षि॥", "मोक्षकाङ्क्षिभिः॥")],
    # Words split by a stray space where the source wrapped a long (tristubh) line.
    (2, 6): [("जिजीविषाम स्तेऽवस्थिताः", "जिजीविषामस्तेऽवस्थिताः")],
    (2, 8): [("ममापनुद्या द्यच्छोक", "ममापनुद्याद्यच्छोक")],
    (2, 20): [("कदाचि न्नायं", "कदाचिन्नायं")],
    (2, 22): [("जीर्णा न्यन्यानि", "जीर्णान्यन्यानि")],
    (2, 29): [("कश्चिदेन माश्चर्य", "कश्चिदेनमाश्चर्य")],
    (8, 9): [("शासितार मणो", "शासितारमणो"), ("चिन्त्यरूप मादित्य", "चिन्त्यरूपमादित्य")],
    (9, 20): [("सुरेन्द्रलोक मश्नन्ति", "सुरेन्द्रलोकमश्नन्ति")],
    (11, 15): [("कमलासनस्थ मृषींश्च", "कमलासनस्थमृषींश्च")],
    (11, 17): [("समन्ता द्दीप्ता", "समन्ताद्दीप्ता")],
    (11, 19): [("न्तवीर्य मनन्तबाहुं", "न्तवीर्यमनन्तबाहुं")],
    (11, 29): [("लोका स्तवापि", "लोकास्तवापि")],
    (11, 30): [("समन्ता ल्लोकान्", "समन्ताल्लोकान्")],
    (11, 38): [("पुराण स्त्वमस्य", "पुराणस्त्वमस्य")],
    (11, 46): [("चक्रहस्त मिच्छामि", "चक्रहस्तमिच्छामि")],
    (11, 48): [("दानै र्न", "दानैर्न")],
    (15, 3): [("सुविरूढमूल मसङ्ग", "सुविरूढमूलमसङ्ग")],
    (15, 5): [("संज्ञै र्गच्छन्त्य", "संज्ञैर्गच्छन्त्य")],
}

# Speaker lines ("X said") as they appear in the source. Sometimes they share a line
# with the verse text instead of standing on their own line.
SPEAKERS = ("धृतराष्ट्र उवाच", "सञ्जय उवाच", "संजय उवाच", "अर्जुन उवाच", "श्री भगवानुवाच", "श्रीभगवानुवाच")

# In these verses the "X said" line falls between the two halves of the verse.
MID_VERSE_SPEAKER = {(1, 21), (1, 28)}


def clean(text: str):
    text = text.replace("\xa0", " ")
    text = text.replace("ृ़", "ॄ")  # long vocalic r typed as r + nukta
    text = text.replace("ो़", "ो")  # stray nukta after a vowel sign
    text = MISPLACED_I.sub(lambda m: "्" + m.group(1) + "ि", text)
    text = MISPLACED_I_CONJUNCT.sub(lambda m: m.group(1) + "्" + m.group(2) + "ि", text)
    text = re.sub(r"।।?\s*\d+\.\d+\s*।।?", "॥", text)  # "।।1.1।।" (or a single closing danda) -> "॥"
    text = text.replace("।।", "॥")
    lines = [re.sub(r"\s+", " ", l).strip() for l in text.splitlines()]
    lines = [l for l in lines if l]
    speaker = ""
    for name in SPEAKERS:
        if lines and lines[0].startswith(name):
            speaker = name
            rest = lines[0][len(name):].strip()
            lines = ([rest] if rest else []) + lines[1:]
            break
    # One line per half-verse: break after a single danda.
    body = " ".join(lines)
    body = re.sub(r"।\s*", "।\n", body).strip()
    return speaker, body


def main():
    source = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
    verses = []
    for v in sorted(source, key=lambda v: (v["chapter_number"], v["verse_number"])):
        speaker, text = clean(v["text"])
        for wrong, right in TYPO_FIXES.get((v["chapter_number"], v["verse_number"]), []):
            if text.count(wrong) != 1:
                sys.exit(f"typo fix for {v['chapter_number']}.{v['verse_number']} does not apply: {wrong!r}")
            text = text.replace(wrong, right)
        if (v["chapter_number"], v["verse_number"]) in MID_VERSE_SPEAKER:
            first, rest = text.split("\n", 1)
            text, speaker = f"{first}\n{speaker}\n{rest}", ""
        verses.append({
            "chapter": v["chapter_number"],
            "verse": v["verse_number"],
            "speaker": speaker,
            "speakerIast": to_iast(speaker),
            "sanskrit": text,
            "iast": to_iast(text),
        })
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({
        "source": "Sanskrit text: public domain. Digital text imported from github.com/gita/gita (The Unlicense). Transliteration generated by tool/iast.py.",
        "verses": verses,
    }, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"wrote {OUT} ({len(verses)} verses)")


if __name__ == "__main__":
    main()
