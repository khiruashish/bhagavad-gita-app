"""Unit tests for the content tools. Run: python3 -m unittest discover -s tool"""
import unittest

import build_content
from iast import to_iast
from import_sanskrit import TYPO_FIXES, clean


class IastTest(unittest.TestCase):
    def test_inherent_vowel_virama_and_marks(self):
        self.assertEqual(to_iast("धर्मक्षेत्रे"), "dharmakṣetre")
        self.assertEqual(to_iast("कर्मण्येवाधिकारस्ते"), "karmaṇyevādhikāraste")
        self.assertEqual(to_iast("युयुत्सवः"), "yuyutsavaḥ")
        self.assertEqual(to_iast("सङ्गोऽस्त्वकर्मणि"), "saṅgo’stvakarmaṇi")
        self.assertEqual(to_iast("पितॄन्"), "pitṝn")
        self.assertEqual(to_iast("ॐ"), "oṃ")

    def test_independent_vowels_and_punctuation(self):
        self.assertEqual(to_iast("अर्जुन उवाच"), "arjuna uvāca")
        self.assertEqual(to_iast("इति।"), "iti|")
        self.assertEqual(to_iast("औ ऐ ऋ"), "au ai ṛ")


class ImportCleanTest(unittest.TestCase):
    def test_speaker_split_and_number_marker(self):
        speaker, text = clean("धृतराष्ट्र उवाच\n\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः।\n\nमामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय।।1.1।।\n ")
        self.assertEqual(speaker, "धृतराष्ट्र उवाच")
        self.assertEqual(text, "धर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः।\nमामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय॥")

    def test_speaker_on_the_same_line_as_the_verse(self):
        speaker, text = clean("श्री भगवानुवाच अशोच्यानन्वशोचस्त्वं प्रज्ञावादांश्च भाषसे।\n\nगतासूनगतासूंश्च नानुशोचन्ति पण्डिताः।।2.11।।")
        self.assertEqual(speaker, "श्री भगवानुवाच")
        self.assertTrue(text.startswith("अशोच्यान"))

    def test_vowel_sign_misplaced_inside_a_conjunct_is_fixed(self):
        _, text = clean("श्रद्धया परया तप्तं तपस्तत्ति्रविधं नरैः।।17.17।।")
        self.assertIn("तपस्तत्त्रिविधं", text)

    def test_verse_marker_with_single_closing_danda_is_removed(self):
        _, text = clean("तत्र श्रीर्विजयो भूतिर्ध्रुवा नीतिर्मतिर्मम।।18.78।")
        self.assertEqual(text, "तत्र श्रीर्विजयो भूतिर्ध्रुवा नीतिर्मतिर्मम॥")

    def test_every_typo_fix_applies_to_the_imported_text(self):
        import json
        import pathlib
        data = json.loads((pathlib.Path(__file__).resolve().parent.parent / "content" / "sanskrit.json").read_text(encoding="utf-8"))
        text = {(v["chapter"], v["verse"]): v["sanskrit"] for v in data["verses"]}
        for key, fixes in TYPO_FIXES.items():
            for _, right in fixes:
                self.assertIn(right, text[key], key)

    def test_misplaced_vowel_sign_is_fixed(self):
        _, text = clean("यच्छ्रेयः स्यान्निश्िचतं ब्रूहि।।2.7।।")
        self.assertIn("निश्चितं", text)


class BuildTest(unittest.TestCase):
    def test_repository_content_is_valid(self):
        out, errors = build_content.build(reviewed_only=False)
        self.assertEqual(errors, [])
        self.assertEqual(len(out["verses"]), 701)
        self.assertEqual(len(out["chapters"]), 18)

    def test_reviewed_only_drops_drafts(self):
        out, _ = build_content.build(reviewed_only=True)
        self.assertTrue(all(v.get("status", "reviewed") == "reviewed" for v in out["verses"]))
        translated = {f"{v['chapter']}.{v['verse']}" for v in out["verses"] if "english" in v}
        self.assertTrue(all(q["id"] in translated for q in out["quotes"]))

    def test_situations_list_existing_translated_verses(self):
        out, _ = build_content.build(reviewed_only=False)
        self.assertGreaterEqual(len(out["situations"]), 10)
        translated = {f"{v['chapter']}.{v['verse']}" for v in out["verses"] if "english" in v}
        for sit in out["situations"]:
            self.assertTrue(set(sit["verses"]) <= translated, sit["id"])

    def test_quotes_cover_every_chapter(self):
        out, _ = build_content.build(reviewed_only=False)
        chapters = {int(q["id"].split(".")[0]) for q in out["quotes"]}
        self.assertEqual(chapters, set(range(1, 19)))


if __name__ == "__main__":
    unittest.main()
