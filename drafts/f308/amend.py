s = open('base.md').read()
def rep(old, new):
    global s
    assert s.count(old) == 1, old[:70]
    s = s.replace(old, new)


# Contract at a glance rows (prettier will realign)
rep("| Behavior                | A SwiftUI `Button` drawn with the Astryx button style, or a SwiftUI `Link` when an enabled Button has `href`. While loading, a spinner covers the label, which keeps its place, and presses wait unless it is interruptible.                                                             |",
    "| Behavior                | A SwiftUI `Button` drawn with the Astryx button style, or a SwiftUI `Link` when an enabled Button has `href`. While loading, a spinner covers the label, which keeps its place, and presses wait unless it is interruptible. On iOS and iPadOS 26 and later, in a system bar or under the floating-glass opt-in, it draws the system's Liquid Glass in place of its own fill: an unset `variant` in a bar becomes the bar's own item, and a set `variant` keeps its meaning in glass. |")
rep("| End-user impact         | A person gets one action control whose width holds while it loads and which never runs twice by accident; a link Button stays a link while busy, so VoiceOver and keyboard focus stay on it.                                                                                             |",
    "| End-user impact         | A person gets one action control whose width holds while it loads and which never runs twice by accident; a link Button stays a link while busy, so VoiceOver and keyboard focus stay on it. In bars and floating controls it looks and behaves like the system's buttons beside it, one layer of glass rather than a fill inside glass, and a main or destructive action still reads as one. |")
rep("| Builder impact          | An app passes core's Button props; `href` makes the same view open a destination through the system.                                                                                                                                                                                     |",
    "| Builder impact          | An app passes core's Button props; `href` makes the same view open a destination through the system. A Button in a bar needs no extra code; one Apple-only modifier on a floating container opts its Buttons into glass. A `variant` the callsite sets is always obeyed. |")
rep("| Review checks           | Reject a loading link that swaps to a button, a loading Button that runs `onClick` or opens its link while not interruptible, a size change while loading, or a disabled Button with `href` that opens.                                                                                  |",
    "| Review checks           | Reject a loading link that swaps to a button, a loading Button that runs `onClick` or opens its link while not interruptible, a size change while loading, or a disabled Button with `href` that opens. Reject an Astryx fill drawn inside a bar's glass, a set `variant` that glass overrides or drops, glass drawn under Reduce Transparency or Increase Contrast, or a glass change merged without the simulator capture gate. |")
rep("| Governing rules         | `component:Button` FR7–FR11; `spec:AST-082` FR3; `spec:AST-093` FR1–FR5; the Swift component API record (A2–A5) under `packages/native/specs/swift/library/`.                                                                                                                            |",
    "| Governing rules         | `component:Button` FR7–FR11; `spec:AST-082` FR3; `spec:AST-093` FR1–FR5; the Swift component API record (A2–A5) under `packages/native/specs/swift/library/`; DEC-1 below. |")

# Ownership
rep("""- How Swift draws core's Button: the SwiftUI control it uses, the loading
  presentation, when presses land, and when `href` makes it a link.""",
"""- How Swift draws core's Button: the SwiftUI control it uses, the loading
  presentation, when presses land, and when `href` makes it a link.
- How Button meets the system's Liquid Glass on Apple platforms: in system bars,
  under the floating-glass opt-in, and under Reduce Transparency or Increase
  Contrast (FR7–FR11).""")
rep("""- How a prop switches to a different SwiftUI control in general — owned by the
  Swift component API record (A2).""",
"""- How a prop switches to a different SwiftUI control in general — owned by the
  Swift component API record (A2).
- The glass itself, how a bar groups its items, and the scroll edge effect —
  owned by the system.
- Search in a navigation context — not a Button concern.""")

# Public concepts row
rep("| availability  | operable; busy-only; disabled | disabled wins over loading                                    | always                                    | operable | `component:Button`       | experimental | none                                        |",
    "| availability  | operable; busy-only; disabled | disabled wins over loading                                    | always                                    | operable | `component:Button`       | experimental | none                                        |\n| surface       | token; bar glass; floating glass; solid | where the Button sits decides what draws behind its label (FR7–FR10) | iOS and iPadOS 26 and later for the glass values | token | `component:swift/Button` | experimental | none |")

# FRs
fr = """| FR7 | On iOS and iPadOS 26 and later, a Button hosted in a system bar (navigation bar or toolbar) whose callsite did not set `variant` MUST defer to the bar: it draws the bar's own item, as a native SwiftUI button there would (label only, on the bar's glass, in the tint the bar gives its items, which `.astryxTheme` sets), and MUST draw no fill, border, or shadow of its own. This needs no new prop or modifier. | DEC-1; Apple's Liquid Glass guidance (remove custom backgrounds in bars) | verify |
| FR8 | A `variant` the callsite sets MUST always be obeyed. In a system bar, and under the floating-glass opt-in (FR9), it maps to the closest glass treatment that keeps its meaning, and is never replaced by the unset treatment or by another variant: `primary` → prominent glass tinted `color.accent`, label `color.onAccent`; `destructive` → prominent glass tinted `color.error`, label `color.onError`; `secondary` → regular glass (in a bar, the bar's own glass), label `color.textPrimary`, no `color.neutral` fill; `ghost` → floating: clear glass, label `color.textPrimary`; in a bar: the bar's own glass, label `color.textPrimary` (the bar owns its items' backgrounds). | DEC-1 | verify |
| FR9 | One Apple-only modifier on a floating container (controls over scrolling content) MUST opt the Buttons inside it into glass, mapped by FR8; an unset `variant` there takes `secondary`'s treatment, `secondary` being core's default. Without the modifier, a Button outside a system bar keeps its token look. The modifier is not a prop and changes no `ButtonProps` (Swift component API A2). | DEC-1 | verify |
| FR10 | Under Reduce Transparency or Increase Contrast, a Button that would draw glass (FR7–FR9) MUST draw no glass: its variant's token fill (`color.accent`, `color.error`, or `color.neutral`; `color.backgroundSurface` for `ghost` and for an unset `variant`) with a `color.borderEmphasized` edge, so its label keeps a solid, visible background. Before iOS 26, and on platforms without Liquid Glass, the token look stays. | DEC-1; `spec:AST-093` FR2 | verify |
| FR11 | In glass, the other props keep their meaning: `isLoading`, `isInterruptible`, `isDisabled`, `href`, and `tooltip` behave as FR2–FR6; `size` sets the label's type size and, floating, the control's height, while a bar sets its items' height; `width: fill` applies when floating, while a bar sizes its items; `elevation` is not drawn on glass, which carries its own depth. A Button's label MUST NOT be truncated by Astryx padding inside a bar that has room for it. | `component:Button` FR7–FR11; DEC-1 | verify |
"""
lines = s.split('\n')
i = next(n for n, l in enumerate(lines) if l.startswith('| FR6 '))
lines[i+1:i+1] = fr.rstrip('\n').split('\n')
s = '\n'.join(lines)

rep("""- **AV1 — Platform controls.** The control is SwiftUI's `Button` or `Link`, so
  focus rings, press feedback, and how the system opens a destination are the
  platform's own.""",
"""- **AV1 — Platform controls.** The control is SwiftUI's `Button` or `Link`, so
  focus rings, press feedback, and how the system opens a destination are the
  platform's own.
- **AV2 — The system's glass.** In glass (FR7–FR9), refraction, how a bar groups
  and morphs its items, press effects, and the scroll edge effect are the
  system's own and may change with each iOS release.""")

rep("| loading with `href`       | a `Link` that does not open until loading ends | none                    |",
"""| loading with `href`       | a `Link` that does not open until loading ends | none                    |
| in a bar, `variant` unset | the bar's own item; no Astryx fill | the system's glass and grouping |
| in a bar, `variant` set | FR8's treatment for that variant | the system's glass and grouping |
| floating, opted in | FR8's treatment; unset takes `secondary`'s | the system's glass |
| Reduce Transparency or Increase Contrast | solid token fill with an edge, no glass | none |""")

rep("""- **ORD1 — Availability.** Disabled, then loading (busy-only unless
  interruptible), then operable, as in core.""",
"""- **ORD1 — Availability.** Disabled, then loading (busy-only unless
  interruptible), then operable, as in core.
- **ORD2 — Surface.** Reduce Transparency or Increase Contrast (solid), then a
  set `variant` (FR8), then an unset `variant` in a bar (FR7) or under the
  floating opt-in (FR9), then the token look. A set `variant` is never
  overridden by placement.""")

rep("""- **AR2 — Rendered tree not measured.**""","""- **AR3 — Glass keeps the name and role.** In glass the Button keeps its label,
  its button or link role, and its loading and disabled states (AR1); the system
  draws only what is behind the label.
- **AR2 — Rendered tree not measured.**""")

rep("| Spinner          | the system's activity indicator | prescribed by the platform | supporting     | FR2, FR4           |",
"""| Spinner          | the system's activity indicator | prescribed by the platform | supporting     | FR2, FR4           |
| Glass surface | the system's Liquid Glass (regular, clear, prominent) | prescribed by the platform | supporting | FR7–FR10 |""")

rep("""Theme values read (`spec:AST-093` FR4): `color.accent`, `color.onAccent`,
`color.error`, `color.onError`, `color.neutral`, `color.textPrimary`,""","""Theme values read (`spec:AST-093` FR4): `color.accent`, `color.onAccent`,
`color.error`, `color.onError`, `color.neutral`, `color.textPrimary`,
`color.backgroundSurface` and `color.borderEmphasized` (the solid fallback),""")

lines = s.split('\n')
i = next(n for n, l in enumerate(lines) if l.startswith('| AR1 ') and 'ButtonTests' in l)
vm = [
"| FR7 | Simulator capture gate: an unset Button in the navigation bar and in the bottom toolbar, light and dark, on each new iOS; a unit test that an unset bar Button draws no fill | navigation bar; bottom toolbar | an Astryx fill inside the bar's glass fails | `audit:swift/Button/glass` |",
"| FR8 | Simulator capture gate: each variant in a bar and floating, light and dark; a unit test of the variant-to-treatment mapping | primary; secondary; ghost; destructive | a set variant drawn as another, or as the unset treatment, fails | `audit:swift/Button/glass` |",
"| FR9 | Simulator capture gate: floating Buttons with and without the modifier; a unit test that the modifier changes no `ButtonProps` | opted in; not opted in | glass without the modifier, or a token fill with it, fails | `audit:swift/Button/glass` |",
"| FR10 | Simulator capture gate with Reduce Transparency and with Increase Contrast on | each variant in a bar and floating | any glass drawn, or a label without a solid background, fails | `audit:swift/Button/glass` |",
"| FR11 | `ButtonTests.swift` loading and disabled tests in glass; simulator capture gate for label truncation in a bar | loading; disabled; long label | a truncated label with room, or a lost loading or disabled state, fails | `audit:swift/Button/glass` |",
]
lines[i+1:i+1] = vm
s = '\n'.join(lines)

rep("""## Decision log

No component-local decision is recorded.""","""## Decision log

### DEC-1 — Button meets the system's glass, and a set variant is always obeyed

**Reference:** `component:swift/Button/DEC-1`
**Decider:** cixzhang, 2026-10-31

iOS 26 draws bar items and floating controls on Liquid Glass, and an Astryx
Button drew its own fill inside the bar's glass and stayed flat over scrolling
content. Button now defers to the bar when its callsite did not set `variant`,
takes glass on a floating container through one Apple-only opt-in, and draws a
solid surface under Reduce Transparency or Increase Contrast. Owner condition,
verbatim: "Buttons naturally have variant so if a callsite is setting it we
should make sure to obey and be the least surprising result for a call". So a
set `variant` keeps its meaning in glass (FR8): primary and destructive stay
the one filled, colored action; secondary and ghost stay neutral.

Rejected: no Astryx glass, with apps using SwiftUI's own buttons in bars and
floating controls — two button systems on one screen, and the theme would reach
those buttons only through the tint.""")

rep("""## Open questions

None.""","""## Open questions

- **OQ1 — Bottom-toolbar detection.** (`gap`) SwiftUI has no public signal that
  a view sits in a system bar. A prototype that reads UIKit's view tree found
  the navigation bar on iOS 26.2 but missed the bottom toolbar. FR7 is not
  verified for the bottom toolbar until a detection passes the capture gate
  there.
- **OQ2 — macOS toolbars.** (`human-api`) macOS 26 toolbars also use Liquid
  Glass; whether FR7–FR10 apply to `NSToolbar` items is not decided.
- **OQ3 — The opt-in's name.** (`human-api`) FR9's modifier is named when it is
  built and reviewed with the public Swift API.""")

rep("""### Allowed variation""", """### Variant mapping in glass

FR7–FR9 in one table. "Least surprising" means a callsite gets what its
`variant` already promises, and a Button looks like the system's buttons beside
it.

| `variant` | In a system bar | Floating, opted in | Least surprising because |
| --- | --- | --- | --- |
| not set | the bar's own item: label in the bar's tint, no fill | regular glass, label `color.textPrimary` (as `secondary`) | the callsite asked for nothing, so it matches the native items beside it |
| `primary` | prominent glass tinted `color.accent`, label `color.onAccent` | the same | still the one filled, accent-colored main action, as the system's prominent bar buttons are |
| `secondary` | the bar's glass, label `color.textPrimary`, no `color.neutral` fill | regular glass, label `color.textPrimary` | still a neutral action; the glass takes the place of the neutral fill, so there is one surface, not two |
| `ghost` | the bar's glass, label `color.textPrimary` (the bar owns its items' backgrounds) | clear glass, label `color.textPrimary` | still the quietest action; clear glass is the least visible surface that keeps the label readable over moving content |
| `destructive` | prominent glass tinted `color.error`, label `color.onError` | the same | still reads as destructive before it is pressed |

### Allowed variation""")

open('out.md','w').write(s)
print('wrote', len(s))
