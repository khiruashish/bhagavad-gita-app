# UI layout

The app has five tabs (Today, Chapters, Quotes, Start here, Settings) and one reader. Every
screen follows the same few rules so it feels calm and is easy for first-time readers.

| Today | Chapters | Chapter | Reader | Quotes |
|---|---|---|---|---|
| ![Today](screenshots/today.png) | ![Chapters](screenshots/chapters.png) | ![Chapter](screenshots/chapter.png) | ![Reader](screenshots/reader.png) | ![Quotes](screenshots/quotes.png) |

| My situation | Situation | Share |
|---|---|---|
| ![Situations](screenshots/situations.png) | ![Situation](screenshots/situation.png) | ![Share](screenshots/share.png) |

## Screens

**Today**: a "Day N" card at the top, with *Previous day* / *Back to today* and a
book icon that opens the same verse in the reader, so the reader can keep going.

**Chapters**: a *Continue reading* card (last verse opened) above 18 chapter cards.
Each card shows the number, the plain-language title, the Sanskrit name and the verse count.

**Chapter**: a header card (title, Sanskrit name, summary, *Start reading*), the verse
list with a short preview of each, and a bottom bar with **← Chapter N-1** and
**Chapter N+1 →**.

**Quotes**: two views, switched at the top.
- *For my situation* (the default): "How are you feeling today?" and a grid of 12
  situations (anxious, angry, grieving, exam pressure, failure, confused, can't focus,
  lonely, comparing, afraid, proud, lazy). Each opens a page with a one-line thought and
  4 or 5 verses, each with its simple meaning. The list is in `content/situations.json`.
- *By chapter*: 58 well-known verses, at least one from every chapter, grouped by chapter.
Chips at the top filter to one chapter. Each card has a short topic line, the translation
in the app's language, the first Sanskrit line, a copy button and *Read verse*. The list
lives in `content/quotes.json`; the build checks that every pick is a complete sentence.

**Reader**: reads the whole Gita as one sequence.
- Top bar: chapter number and title, with **⏮ previous chapter** and **⏭ next chapter**.
  A thin progress bar shows how far through the chapter you are.
- Bottom bar: **← Previous**, the position (`12 / 47`) and **Next →**. On the last verse
  of a chapter, Next reads **Chapter N+1 →** and carries straight on. Swiping does the same.
- The last verse opened is saved, for *Continue reading*.

**Search** (top bar on Today, Chapters and Quotes): type a verse number like `2.47`,
`2 47` or `2:47` to jump to it, or words in English, Hindi or Roman-letter Sanskrit
(diacritics optional). Matches in the translations and simple meanings are listed first.

**My verses** (heart in the top bar, or Settings): saved verses and private notes.

**Reading progress**: a verse counts as read when shown as the daily verse or opened in
the reader. Chapter cards show "12 of 47 read" with a bar; verse lists show a tick.
Settings → *Clear reading progress* resets it.

**Think about it**: under the daily verse, one of three questions for its chapter
(`content/reflections.json`), with *Write a note*.

**Home-screen widget (Android)**: today's verse on a saffron card; tap to open the app.

**Share as image**: the share icon on a verse or card opens a preview of a 4:5 picture
(1080 x 1350, the shape WhatsApp Status and Instagram show best): Sanskrit, the
translation in Hindi or English (switch in the sheet), the verse number and the app's
name. *Share* opens the phone's share menu.

**Verse** (used by Today and the reader), from top to bottom:
1. Verse badge (`2.47`), "Chapter 2 · Verse 47", who is speaking; copy, save (heart) and share buttons.
2. A quiet draft notice while the translation is unreviewed.
3. Sanskrit card: Devanagari in the bundled Noto Serif Devanagari font, a divider, then pronunciation. Listen button.
4. Translation cards, in the app's language first, each with its own Listen button.
5. "In simple words", in a differently coloured card.

## Design rules

- **One accent colour** (saffron, from the theme seed). Sanskrit is the warmest card,
  translations are white cards, and the simple meaning has its own colour.
- **Cards**: 20 px corners, no shadow, a thin outline.
- **Touch targets** of at least 48 px. Primary action filled, secondary outlined.
- **Text** at the phone's own size times the in-app size setting. Reading width is
  capped at 720 px on tablets.
- **Light and dark themes** come from the same colour scheme. Nothing is hard-coded
  except the light page background.
- Previous/next controls are always in the same place, at the bottom, within thumb reach.

## Ideas for later

- Bookmarks and a "favourites" list.
- Search by word or verse number.
- A one-tap "share as image" card for the daily verse.
- A reading streak and a gentle daily reminder notification (needs a permission prompt
  and a privacy-policy update).
- A bundled Devanagari font such as Noto Serif Devanagari (OFL licence), so Sanskrit
  looks the same on every phone.
