"""Devanagari -> IAST transliteration, written for this project (no third-party data).

Mechanical, rule-based conversion of Sanskrit in Devanagari script to the
International Alphabet of Sanskrit Transliteration.
"""

VOWELS = {
    "अ": "a", "आ": "ā", "इ": "i", "ई": "ī", "उ": "u", "ऊ": "ū", "ऋ": "ṛ", "ॠ": "ṝ",
    "ऌ": "ḷ", "ॡ": "ḹ", "ए": "e", "ऐ": "ai", "ओ": "o", "औ": "au",
}
MATRAS = {
    "ा": "ā", "ि": "i", "ी": "ī", "ु": "u", "ू": "ū", "ृ": "ṛ", "ॄ": "ṝ",
    "ॢ": "ḷ", "ॣ": "ḹ", "े": "e", "ै": "ai", "ो": "o", "ौ": "au",
}
CONSONANTS = {
    "क": "k", "ख": "kh", "ग": "g", "घ": "gh", "ङ": "ṅ",
    "च": "c", "छ": "ch", "ज": "j", "झ": "jh", "ञ": "ñ",
    "ट": "ṭ", "ठ": "ṭh", "ड": "ḍ", "ढ": "ḍh", "ण": "ṇ",
    "त": "t", "थ": "th", "द": "d", "ध": "dh", "न": "n",
    "प": "p", "फ": "ph", "ब": "b", "भ": "bh", "म": "m",
    "य": "y", "र": "r", "ल": "l", "व": "v",
    "श": "ś", "ष": "ṣ", "स": "s", "ह": "h", "ळ": "ḷ",
}
OTHER = {
    "ं": "ṃ", "ः": "ḥ", "ँ": "m̐", "ऽ": "’", "ॐ": "oṃ",
    "।": "|", "॥": "||",
    "०": "0", "१": "1", "२": "2", "३": "3", "४": "4",
    "५": "5", "६": "6", "७": "7", "८": "8", "९": "9",
}
VIRAMA = "्"
NUKTA = "़"


def to_iast(text: str) -> str:
    out = []
    i, n = 0, len(text)
    while i < n:
        ch = text[i]
        if ch in CONSONANTS:
            out.append(CONSONANTS[ch])
            j = i + 1
            if j < n and text[j] == NUKTA:
                j += 1
            nxt = text[j] if j < n else ""
            if nxt in MATRAS:
                out.append(MATRAS[nxt])
                j += 1
            elif nxt == VIRAMA:
                j += 1
            else:
                out.append("a")
            i = j
            continue
        if ch in VOWELS:
            out.append(VOWELS[ch])
        elif ch in OTHER:
            out.append(OTHER[ch])
        elif ch in MATRAS or ch in (VIRAMA, NUKTA):
            pass  # stray mark without a consonant; drop it
        else:
            out.append(ch)
        i += 1
    return "".join(out)
