# Icon and store artwork

The icon shows Krishna and Arjuna on the chariot (the Gita teaching scene) in
silhouette, against the sun on saffron. It is vector art drawn for this project.

| File | Use |
|---|---|
| `source/icon_full.svg` | Master artwork (background + figures) |
| `source/icon_bg.svg`, `source/icon_fg.svg` | Android adaptive icon layers (figures kept inside the safe zone) |
| `play-icon-512.png` | Google Play store icon |
| `app-store-icon-1024.png` | App Store icon (no transparency) |

The SVGs come from `tool/make_icon_svg.py`. The app's own icon files were rendered from them:

- Android: `android/app/src/main/res/mipmap-*/ic_launcher*.png`, `mipmap-anydpi-v26/*.xml`
  (adaptive + themed/monochrome), `drawable-*/launch_image.png` (splash)
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png`, `LaunchImage.imageset/*.png`
- In-app: `assets/icon/icon.png` (About screen)

**To replace the artwork** (e.g. commissioned or AI-generated art): start from a
1024 × 1024 PNG, keep the main subject inside the central ~60% (Android crops adaptive
icons to a circle or squircle), export the same sizes, and replace the files above. Make
sure you have the rights to use it in a free app on both stores.
