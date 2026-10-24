# Vendored from facebook/astryx (MIT)

`platforms.ts` and `theme/defineNativeTheme.ts` are byte-for-byte copies of
`packages/native/src/` at facebook/astryx `main` commit
`d76a228ef05f044eb653c5602d0628693c08f692`. They are vendored so the spike's
`pixelNativeTheme` type-checks against the real types on main
(`@astryxdesign/native` is canary-only and its canary peers conflict with this
gallery's core 0.6). Do not edit; re-copy to update.
