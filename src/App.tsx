import { useEffect, useState } from 'react'
import { Avatar } from '@astryxdesign/core/Avatar'
import { Banner } from '@astryxdesign/core/Banner'
import { CheckboxInput } from '@astryxdesign/core/CheckboxInput'
import { RadioList, RadioListItem } from '@astryxdesign/core/RadioList'
import { SegmentedControl, SegmentedControlItem } from '@astryxdesign/core/SegmentedControl'
import { Slider } from '@astryxdesign/core/Slider'
import type { PixelPaletteName } from './studio/pixel-theme.tsx'
import avatarUrl from './assets/avatar.jpg'
import { Badge } from '@astryxdesign/core/Badge'
import { Button } from '@astryxdesign/core/Button'
import { Card } from '@astryxdesign/core/Card'
import { Heading } from '@astryxdesign/core/Heading'
import { Icon } from '@astryxdesign/core/Icon'
import { CodeBlock } from '@astryxdesign/core/CodeBlock'
import { Link } from '@astryxdesign/core/Link'
import { ProgressBar } from '@astryxdesign/core/ProgressBar'
import { HStack, VStack } from '@astryxdesign/core/Stack'
import { Switch } from '@astryxdesign/core/Switch'
import { Text } from '@astryxdesign/core/Text'
import { TextInput } from '@astryxdesign/core/TextInput'
import { ToggleButton } from '@astryxdesign/core/ToggleButton'

type AppProps = {
  pixel: number
  onPixelChange: (p: number) => void
  palette: PixelPaletteName
  onPaletteChange: (p: PixelPaletteName) => void
  mode: 'light' | 'dark'
  onModeChange: (m: 'light' | 'dark') => void
}

const PALETTES: Array<{ value: PixelPaletteName; label: string }> = [
  { value: 'garden', label: 'Garden' },
  { value: 'gameboy', label: 'Game Boy' },
  { value: 'nes', label: 'NES' },
  { value: 'c64', label: 'C64' },
  { value: 'pico8', label: 'PICO-8' },
]

const PLOTS = [
  { name: 'astryx: fix tokens', status: 'Ready', variant: 'success' as const, health: 100 },
  { name: 'astryx: add pixel theme', status: 'Growing', variant: 'info' as const, health: 64 },
  { name: 'forest: sprite import', status: 'Wilting', variant: 'warning' as const, health: 28 },
  { name: 'glyphdance: space cat', status: 'Blocked', variant: 'error' as const, health: 8 },
]

/** Bake an image down to `cells`x`cells` (halving steps, like the round-2
 *  avatar finding) so displaying it at 48px shows one image pixel per
 *  grid cell — the sprite-pipeline treatment for photos. */
function usePixelatedSrc(src: string, cells: number): string {
  const [out, setOut] = useState(src)
  useEffect(() => {
    let live = true
    const img = new Image()
    img.onload = () => {
      let w = img.naturalWidth
      let h = img.naturalHeight
      let cur: CanvasImageSource = img
      while (w / 2 >= cells && h / 2 >= cells) {
        const c = document.createElement('canvas')
        c.width = Math.round(w / 2)
        c.height = Math.round(h / 2)
        c.getContext('2d')!.drawImage(cur, 0, 0, c.width, c.height)
        cur = c
        w = c.width
        h = c.height
      }
      const final = document.createElement('canvas')
      final.width = cells
      final.height = cells
      final.getContext('2d')!.drawImage(cur, 0, 0, cells, cells)
      if (live) setOut(final.toDataURL())
    }
    img.src = src
    return () => {
      live = false
    }
  }, [src, cells])
  return out
}

const ICON_SHOWCASE = [
  'search', 'calendar', 'clock', 'check', 'close', 'success', 'error', 'warning', 'info',
  'menu', 'moreHorizontal', 'chevronDown', 'chevronLeft', 'chevronRight', 'arrowUp', 'arrowDown',
  'funnel', 'copy', 'checkDouble', 'externalLink', 'eyeSlash', 'viewColumns', 'wrench', 'stop', 'microphone',
] as const

export default function App({ pixel, onPixelChange, palette, onPaletteChange, mode, onModeChange }: AppProps) {
  const [harvested, setHarvested] = useState(0)
  const [autoWater, setAutoWater] = useState(true)
  const [plotName, setPlotName] = useState('tend the garden')
  const [waterLevel, setWaterLevel] = useState(60)
  const [mulched, setMulched] = useState(true)
  const [fenced, setFenced] = useState(false)
  const [season, setSeason] = useState('spring')
  const [tool, setTool] = useState('water')
  const avatarCells = 48 / pixel
  const pixelAvatar = usePixelatedSrc(avatarUrl, avatarCells)

  return (
    <VStack gap={8} padding={8}>
      {/* ── Header + pixel-unit switcher ─────────────────────────── */}
      <VStack gap={4}>
        <Heading level={1}>Pixel Theme Gallery</Heading>
        <Text type="supporting">
          A pure defineTheme config. One number — the pixel unit P — drives the type scale,
          spacing, borders and corners, so the UI pixels can match the app&apos;s sprite scale.
        </Text>
        <HStack gap={3} align="center">
          <Text type="label">Pixel unit</Text>
          {[2, 3, 4].map((p) => (
            <ToggleButton
              key={p}
              label={`P = ${p}`}
              isPressed={pixel === p}
              onPressedChange={() => onPixelChange(p)}
            />
          ))}
          <Text type="supporting">
            body text = Silkscreen {8 * pixel}px · borders {pixel}px · spacing snapped to {pixel}px
          </Text>
        </HStack>
        <HStack gap={3} align="center" wrap="wrap">
          <Text type="label">Palette</Text>
          <SegmentedControl
            label="Colour palette"
            value={palette}
            onChange={(v) => onPaletteChange(v as PixelPaletteName)}
          >
            {PALETTES.map((p) => (
              <SegmentedControlItem key={p.value} value={p.value} label={p.label} />
            ))}
          </SegmentedControl>
          <ToggleButton
            label="Dark"
            isPressed={mode === 'dark'}
            onPressedChange={(pressed) => onModeChange(pressed ? 'dark' : 'light')}
          />
        </HStack>
        <Banner
          status="warning"
          title="World tree health dropping"
          description="Two plots are wilting. Banners take the stepped corner too."
          collapsible={false}
        />
      </VStack>

      {/* ── Type specimen ────────────────────────────────────────── */}
      <Card>
        <VStack gap={4}>
          <Text type="display-1">Repo Garden</Text>
          <Heading level={1}>Heading 1 — {16 * pixel}px Silkscreen</Heading>
          <Heading level={3}>Heading 3 — {8 * pixel}px, bold carries the hierarchy</Heading>
          <Text type="body">
            Body text sits at {8 * pixel}px because Silkscreen&apos;s design pixel is size/8:
            only multiples of 8P point-sample cleanly on a {pixel}px grid.
          </Text>
          <Text type="label">Label — same size, bold</Text>
          <Text type="supporting">Supporting — same size, secondary colour</Text>
          <Text type="code">Code — Silkscreen as well; one grid font everywhere</Text>
        </VStack>
      </Card>

      <HStack gap={6} wrap="wrap">
        {/* ── Buttons ────────────────────────────────────────────── */}
        <Card>
          <VStack gap={4}>
            <Heading level={2}>Buttons</Heading>
            <HStack gap={3} wrap="wrap">
              <Button label="Harvest" variant="primary" />
              <Button label="Water" variant="secondary" />
              <Button label="Prune" variant="ghost" />
              <Button label="Uproot" variant="destructive" />
            </HStack>
            <HStack gap={3} wrap="wrap">
              <Button label="Small" variant="primary" size="sm" />
              <Button label="Medium" variant="primary" size="md" />
              <Button label="Large" variant="primary" size="lg" />
              <Button label="Disabled" variant="primary" isDisabled />
            </HStack>
          </VStack>
        </Card>

        {/* ── Badges + progress ──────────────────────────────────── */}
        <Card>
          <VStack gap={4}>
            <Heading level={2}>Badges + Progress</Heading>
            <HStack gap={3} wrap="wrap">
              <Badge label="Ready" variant="success" />
              <Badge label="Growing" variant="info" />
              <Badge label="Wilting" variant="warning" />
              <Badge label="Blocked" variant="error" />
              <Badge label="+3 plots" variant="green" />
            </HStack>
            <ProgressBar label="World tree health" value={72} max={100} variant="accent" hasValueLabel />
            <ProgressBar label="Water" value={45} max={100} variant="warning" hasValueLabel />
            <ProgressBar label="Sunlight" value={91} max={100} variant="success" hasValueLabel />
          </VStack>
        </Card>
      </HStack>

      <HStack gap={6} wrap="wrap">
        {/* ── Form ───────────────────────────────────────────────── */}
        <Card>
          <VStack gap={4}>
            <Heading level={2}>Form</Heading>
            <TextInput
              label="Current task"
              value={plotName}
              onChange={setPlotName}
              description="Labels and inputs share the 8P text size."
            />
            <Switch label="Auto-water at dawn" value={autoWater} onChange={setAutoWater} />
            <TextInput label="Seed packet (locked)" value="AST-067" isReadOnly />
          </VStack>
        </Card>

        {/* ── Avatars ────────────────────────────────────────────── */}
        <Card>
          <VStack gap={4}>
            <Heading level={2}>Avatars</Heading>
            <HStack gap={4} align="center">
              <Avatar src={pixelAvatar} name="Cindy Zhang" size="lg" shape="circle" />
              <Avatar src={pixelAvatar} name="Cindy Zhang" size="lg" shape="rounded" />
              <Avatar src={pixelAvatar} name="Cindy Zhang" size="lg" shape="square" />
            </HStack>
            <Text type="supporting">
              Circle is a staircase pixel-circle, rounded the stepped corner — and the photo
              itself is baked to {avatarCells}x{avatarCells}, one image pixel per grid cell.
            </Text>
          </VStack>
        </Card>
      </HStack>

      <HStack gap={6} wrap="wrap">
        {/* ── Controls — the rest of the set, pixelated ── */}
        <Card>
          <VStack gap={4}>
            <Heading level={2}>Controls</Heading>
            <Slider label="Water level" value={waterLevel} onChange={setWaterLevel} valueDisplay="text" />
            <CheckboxInput label="Mulched" value={mulched} onChange={setMulched} />
            <CheckboxInput label="Fenced" value={fenced} onChange={setFenced} />
            <RadioList label="Season" value={season} onChange={setSeason}>
              <RadioListItem label="Spring" value="spring" />
              <RadioListItem label="Summer" value="summer" />
              <RadioListItem label="Autumn" value="autumn" />
            </RadioList>
            <SegmentedControl label="Garden tool" value={tool} onChange={setTool}>
              <SegmentedControlItem value="water" label="Water" />
              <SegmentedControlItem value="feed" label="Feed" />
              <SegmentedControlItem value="prune" label="Prune" />
            </SegmentedControl>
          </VStack>
        </Card>
      </HStack>

      {/* ── Repo Garden composite — the gardening app in miniature ── */}
      <Card>
        <VStack gap={5}>
          <HStack gap={4} justify="between" align="center">
            <Heading level={2}>Repo Garden — plots</Heading>
            <Badge label={`Harvested ${harvested}`} variant="green" />
          </HStack>
          {PLOTS.map((plot) => (
            <HStack key={plot.name} gap={4} justify="between" align="center">
              <VStack gap={1}>
                <Text type="body">{plot.name}</Text>
                <ProgressBar label={`${plot.name} health`} value={plot.health} max={100} isLabelHidden />
              </VStack>
              <Badge label={plot.status} variant={plot.variant} />
            </HStack>
          ))}
          <HStack gap={3}>
            <Button label="Harvest ready plots" variant="primary" onClick={() => setHarvested((n) => n + 3)} />
            <Button label="Water all" variant="secondary" />
          </HStack>
        </VStack>
      </Card>

      {/* ── Icons — matrix glyphs from the theme ── */}
      <Card>
        <VStack gap={4}>
          <Heading level={2}>Icons — drawn as pixel matrices</Heading>
          <HStack gap={4} wrap="wrap">
            {ICON_SHOWCASE.map((name) => (
              <Icon key={name} icon={name} size="lg" />
            ))}
          </HStack>
          <Text type="supporting">
            Every Astryx semantic icon is a 12x12 pixel matrix in the theme — the grid-font
            treatment for glyphs. The radio dot and checkbox check above are pixel indicators
            from the same file.
          </Text>
        </VStack>
      </Card>

      {/* ── Use it ─────────────────────────────────────────────── */}
      <Card>
        <VStack gap={4}>
          <Heading level={2}>Use the theme</Heading>
          <Link href="https://github.com/cixzhang/astryx-pixel-gallery" isExternalLink>
            cixzhang/astryx-pixel-gallery on GitHub
          </Link>
          <CodeBlock
            title="Install — two files, one build"
            language="bash"
            code={`# grab the theme: the factory + its pixel icons/indicators
curl -O https://raw.githubusercontent.com/cixzhang/astryx-pixel-gallery/main/src/studio/pixel-theme.tsx
curl -O https://raw.githubusercontent.com/cixzhang/astryx-pixel-gallery/main/src/studio/pixel-icons.tsx

# build it with the Astryx CLI
npx astryx theme build src/studio/pixel-theme.tsx`}
          />
          <CodeBlock
            title="Apply it"
            language="tsx"
            code={`import { Theme } from '@astryxdesign/core/theme'
import { createPixelTheme } from './studio/pixel-theme'

// P is the pixel unit in CSS px — match it to your sprite scale.
// palette: 'garden' | 'gameboy' | 'nes' | 'c64' | 'pico8'
const theme = createPixelTheme(3, 'gameboy')

<Theme theme={theme} mode="dark">
  <App />
</Theme>`}
          />
          <Text type="supporting">
            Silkscreen ships separately (the theme names it; loading fonts is the app's job) —
            the two .ttf files are in the repo under src/assets/fonts.
          </Text>
        </VStack>
      </Card>

      {/* ── Leakage summary ──────────────────────────────────────── */}
      <Card>
        <VStack gap={3}>
          <Heading level={2}>What defineTheme could not say</Heading>
          <Text type="body">
            Full log in LEAKAGE.md. In short: fonts are named, not loaded; the type hierarchy
            compresses to three sizes by design; page background patterns, scrollbars, selection
            styling and the Spinner's keyframes have no theme surface.
          </Text>
        </VStack>
      </Card>
    </VStack>
  )
}
