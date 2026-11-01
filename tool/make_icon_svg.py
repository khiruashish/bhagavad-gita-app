"""Builds the app icon SVGs: Krishna and Arjuna on the chariot, in silhouette."""
import math, sys

INK = "#3E1408"
GOLD = "#FFE7AE"

def figure_paths():
    p = []
    # Chariot floor and front guard
    p.append('<path d="M285 640 L785 640 L765 684 L305 684 Z"/>')
    p.append('<path d="M285 642 Q258 590 296 548 L314 556 Q290 596 310 642 Z"/>')
    # Wheel: rim, hub, spokes
    cx, cy, r = 470, 776, 108
    p.append(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{INK}" stroke-width="26"/>')
    p.append(f'<circle cx="{cx}" cy="{cy}" r="26"/>')
    for i in range(8):
        a = math.pi * i / 4
        p.append(f'<line x1="{cx}" y1="{cy}" x2="{cx + r * math.cos(a):.1f}" y2="{cy + r * math.sin(a):.1f}" stroke="{INK}" stroke-width="12"/>')
    # Flag pole and flag
    p.append('<rect x="758" y="246" width="13" height="396" rx="4"/>')
    p.append('<path d="M771 252 Q830 262 884 292 Q830 318 771 330 Z"/>')
    # Krishna, standing, hand raised in teaching
    p.append('<circle cx="395" cy="384" r="35"/>')
    p.append('<path d="M362 360 L368 326 L382 344 L395 314 L408 344 L422 326 L428 360 Z"/>')
    p.append('<path d="M410 338 Q452 300 450 252 Q440 228 424 250 Q406 290 410 338 Z"/>')
    p.append(f'<ellipse cx="440" cy="262" rx="8" ry="13" transform="rotate(20 440 262)" fill="{GOLD}"/>')
    p.append('<ellipse cx="440" cy="262" rx="3.5" ry="6" transform="rotate(20 440 262)"/>')
    p.append('<path d="M366 418 L424 418 Q426 466 414 500 Q440 560 466 640 L326 640 Q350 560 376 500 Q364 466 366 418 Z"/>')
    p.append('<path d="M368 424 Q330 470 318 560 Q314 600 300 630 L316 632 Q336 590 342 540 Q350 486 380 440 Z"/>')
    p.append(f'<path d="M416 432 L468 470 L484 412" fill="none" stroke="{INK}" stroke-width="22" stroke-linecap="round" stroke-linejoin="round"/>')
    p.append('<ellipse cx="487" cy="398" rx="12" ry="18"/>')
    p.append(f'<path d="M372 434 L346 512" fill="none" stroke="{INK}" stroke-width="20" stroke-linecap="round"/>')
    # Arjuna, kneeling with folded hands, facing Krishna
    p.append('<circle cx="612" cy="500" r="31"/>')
    p.append('<path d="M586 480 L592 452 L604 468 L613 444 L622 468 L634 454 L638 480 Z"/>')
    p.append('<path d="M594 530 L632 530 Q640 560 644 594 L668 640 L556 640 L556 612 Q562 598 596 594 Z"/>')
    p.append(f'<path d="M600 546 L566 576 L556 540" fill="none" stroke="{INK}" stroke-width="18" stroke-linecap="round" stroke-linejoin="round"/>')
    p.append('<path d="M548 548 Q552 514 560 504 Q570 520 566 550 Z"/>')
    # Bow resting beside Arjuna
    p.append(f'<path d="M712 452 Q782 548 712 640" fill="none" stroke="{INK}" stroke-width="13" stroke-linecap="round"/>')
    p.append(f'<line x1="712" y1="452" x2="712" y2="640" stroke="{INK}" stroke-width="4"/>')
    return "\n    ".join(p)

def background(rounded=False):
    clip = ' rx="0"'
    return f'''<defs>
    <linearGradient id="bg" x1="0" y1="0" x2="0.4" y2="1">
      <stop offset="0" stop-color="#F6A53C"/>
      <stop offset="1" stop-color="#C24A16"/>
    </linearGradient>
    <radialGradient id="sun" cx="0.5" cy="0.5" r="0.5">
      <stop offset="0" stop-color="#FFF4D2"/>
      <stop offset="0.7" stop-color="#FFE1A0"/>
      <stop offset="1" stop-color="#FFD58A" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="1024" height="1024" fill="url(#bg)"{clip}/>
  <circle cx="512" cy="455" r="340" fill="url(#sun)"/>
  <circle cx="512" cy="455" r="255" fill="#FFE9B5" opacity="0.85"/>'''

def svg(kind, scale):
    fg = f'<g fill="{INK}" transform="translate(512 512) scale({scale}) translate(-585 -572)">\n    {figure_paths()}\n  </g>'
    parts = []
    if kind in ("full", "bg"): parts.append(background())
    if kind in ("full", "fg"): parts.append(fg)
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">\n  {"".join(parts)}\n</svg>\n'

if __name__ == "__main__":
    out = sys.argv[1]
    open(f"{out}/icon_full.svg", "w").write(svg("full", 1.08))
    open(f"{out}/icon_bg.svg", "w").write(svg("bg", 1.0))
    open(f"{out}/icon_fg.svg", "w").write(svg("fg", 0.78))
