# Master content prompts

Use these with an AI assistant to draft original content. Everything drafted is
`"status": "draft"` until the similarity check passes and a human scholar has reviewed it
(see `docs/GUIDE.md`, Steps 4–5). Never paste published translations into the
conversation, not even "for reference".

---

## Prompt 1: translate a batch of verses

Fill in `{{CHAPTER}}` and `{{VERSES}}`. Copy the verses from `content/sanskrit.json`,
leaving out the speaker lines (the app adds those itself). Use batches of about 10 verses.

````markdown
# ROLE
You are a Sanskrit scholar and a translator who writes for ordinary readers. You read the
Bhagavad Gita in the original and translate directly from the Devanagari. Your English
and Hindi are plain, exact and unhurried, without ornament.

# TASK
For each verse of Chapter {{CHAPTER}} below, write:
1. an English translation,
2. a Hindi translation,
3. a "simple meaning" in English: 1–3 short sentences for someone who has never read the
   Gita. Say what is happening or what the verse teaches, and explain any name or idea a
   beginner would not know,
4. the same simple meaning in Hindi (written in Hindi, not translated word for word from
   your English).
Work only from the Sanskrit given here.

# SOURCE TEXT
{{VERSES}}

# ORIGINALITY RULES (most important)
1. Translate from the Sanskrit in front of you. Do not recall, quote, paraphrase or imitate
   any published translation or commentary, including Prabhupada, Sivananda,
   Gambhirananda, Chinmayananda, Tejomayananda, Ramsukhdas, Mukundananda, Easwaran,
   Mitchell, Radhakrishnan, Besant, Arnold or Gita Press.
2. Many verses have a famous English phrasing (2.47, 2.20, 4.7, 18.66, …). If your
   sentence matches one you recognise, rebuild it from the Sanskrit and choose different
   but accurate words and sentence structure.
3. No commentary, devotional framing or doctrine inside the translation. A word supplied
   for sense goes in [square brackets], used sparingly.
4. Stay neutral between schools (Advaita, Vishishtadvaita, Dvaita, Gaudiya…). Where the
   Sanskrit is genuinely ambiguous, use the plainest grammatical reading and explain the
   choice in "notes".

# STYLE RULES
- Write like a careful human translator, not an explainer. One verse = one to three
  sentences. Vary sentence length and structure from verse to verse.
- Concrete, ordinary words. Never use: delve, journey, tapestry, profound, embark, realm,
  navigate, essence, timeless, ultimately, truly, "it is important to", "in essence".
- No rhetorical questions or exclamation marks unless the Sanskrit has them. Few dashes.
- Krishna sounds calm and direct; Arjuna anxious and searching; Sanjaya plain.
- Do not start with "Arjuna said:" etc.; the app shows the speaker separately. If a
  speaker line falls in the middle of a verse, keep it in the text.
- Names without diacritics in translations: Arjuna, Krishna, Partha, Kaunteya, Bharata,
  Keshava, Madhava. Keep vocatives only where the Sanskrit has them.
- Hindi: clear modern Hindi an ordinary reader understands; tatsama words where natural,
  no heavy archaic phrasing. Translate from the Sanskrit, not from your English.
- Simple meanings: warm, plain, respectful. No preaching, no "this verse teaches us that
  we should…". No claims about history or science.
- Sensitive verses (e.g. 1.40–1.44, 9.32, 16.x, 18.41–48): translate faithfully and use the
  simple meaning to give neutral context, e.g. whose view it is and the social setting of
  the time. Do not soften the translation itself.

# FIXED GLOSSARY (use exactly, every time)
| Sanskrit | English | Hindi |
|---|---|---|
| dharma | dharma ("one's own duty" for svadharma) | धर्म |
| karma | action | कर्म |
| yoga | yoga | योग |
| ātman | the Self (capital S) | आत्मा |
| brahman | Brahman | ब्रह्म |
| jñāna / vijñāna | knowledge / realised knowledge | ज्ञान / विज्ञान |
| bhakti | devotion | भक्ति |
| buddhi / manas | understanding / mind | बुद्धि / मन |
| guṇa | quality (sattva, rajas, tamas untranslated) | गुण |
| prakṛti / puruṣa | nature / spirit | प्रकृति / पुरुष |
| yajña | offering | यज्ञ |
| saṃnyāsa / tyāga | renunciation / relinquishment | संन्यास / त्याग |
| kṣetra / kṣetrajña | the field / the knower of the field | क्षेत्र / क्षेत्रज्ञ |
| phala / saṅga | fruit (of action) / attachment | फल / आसक्ति |

# OUTPUT
Return ONLY valid JSON in exactly this shape (it is pasted into content/translations/):
{
  "chapter": {{CHAPTER}},
  "verses": [
    {
      "number": 1,
      "english": "...",
      "hindi": "...",
      "simpleEnglish": "...",
      "simpleHindi": "...",
      "notes": "only if a reading was genuinely uncertain; otherwise omit this field",
      "status": "draft"
    }
  ]
}

# SELF-CHECK (silently, before answering)
- Every Sanskrit word is reflected; nothing added except [brackets].
- Glossary terms used exactly. No banned words. Sentence shapes vary.
- Nothing matches a published translation you can recall.
- The Hindi reads naturally and matches the English in meaning.
- The JSON parses.
````

---

## Prompt 2: rewrite verses the similarity check flagged

````markdown
The similarity checker says these drafts are too close to an existing published
translation. Rewrite each one from the Sanskrit with different sentence structure and
word choice, keeping the same meaning, glossary and style rules as before. Lists of names
must keep the names; change the sentence around them. Return the same JSON shape, with
only the verses listed.

Sanskrit and current drafts:
{{FLAGGED_VERSES_WITH_SANSKRIT_AND_DRAFT}}
````

(Do not paste the published translation that was matched. Rewrite from the Sanskrit.)

---

## Prompt 3: chapter summary (once per chapter)

````markdown
Here is the full Sanskrit of Chapter {{CHAPTER}} with our own translation. Write a summary
of 2–4 plain sentences in English and the same in Hindi, for someone new to the Gita: what
happens and what is taught, in order. No headings, bullet points, praise words or closing
moral. Do not reuse any published chapter summary. Return JSON:
{"number": {{CHAPTER}}, "summaryEnglish": "...", "summaryHindi": "..."}

{{CHAPTER_TEXT}}
````

---

## Prompt 4: reviewer checklist (give this to the human scholar)

For each verse, check:
1. **Accuracy:** does the English and Hindi say what the Sanskrit says, no more and no less?
2. **Naturalness:** would a careful human translator write it this way?
3. **Simple meaning:** correct, neutral, and understandable by a 12-year-old?
4. **Originality:** does any line sound like a translation you have read before? If so,
   rewrite it.
5. **Consistency:** glossary terms and names follow the tables above.

When a verse is correct, set `"status": "reviewed"` and `"reviewedBy": "<your name>"`.
