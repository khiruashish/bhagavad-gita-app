"""Unit tests for the content tools. Run: python3 -m unittest discover -s tool"""
import unittest

import build_content
from iast import to_iast
from import_sanskrit import clean


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


if __name__ == "__main__":
    unittest.main()
