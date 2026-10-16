import { StrictMode, useMemo, useState } from 'react'
import { createRoot } from 'react-dom/client'
import '@astryxdesign/core/reset.css'
import '@astryxdesign/core/astryx.css'
import { Theme } from '@astryxdesign/core/theme'
import { InternationalizationProvider } from '@astryxdesign/core/i18n'
import { createPixelTheme, type PixelPaletteName } from './studio/pixel-theme.tsx'
import './fonts.css'
import App from './App.tsx'

/**
 * The theme is a function of three choices: the pixel unit P, a retro
 * palette, and light/dark. Switching any of them re-derives the whole
 * token set. In production you would build one combination with
 * `astryx theme build` instead (src/studio/pixel.css is garden @ P=3).
 */
function Root() {
  const [pixel, setPixel] = useState(3)
  const [palette, setPalette] = useState<PixelPaletteName>('garden')
  const [mode, setMode] = useState<'light' | 'dark'>('light')
  const theme = useMemo(() => createPixelTheme(pixel, palette), [pixel, palette])
  return (
    <InternationalizationProvider locale="en" dir="ltr">
      <Theme theme={theme} mode={mode}>
        <App
          pixel={pixel}
          onPixelChange={setPixel}
          palette={palette}
          onPaletteChange={setPalette}
          mode={mode}
          onModeChange={setMode}
        />
      </Theme>
    </InternationalizationProvider>
  )
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Root />
  </StrictMode>,
)
