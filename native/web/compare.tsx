// Web side of the native SwiftUI comparison (spike). Renders the same
// content as native/App/Sources/CompareScreens.swift with the pixel theme.
// Query: ?mode=light|dark&view=components|login
import { useState, type CSSProperties } from 'react'
import { createRoot } from 'react-dom/client'
import '@astryxdesign/core/reset.css'
import '@astryxdesign/core/astryx.css'
import { Theme } from '@astryxdesign/core/theme'
import { InternationalizationProvider } from '@astryxdesign/core/i18n'
import { VStack, HStack } from '@astryxdesign/core/Layout'
import { Center } from '@astryxdesign/core/Center'
import { Text, Heading } from '@astryxdesign/core/Text'
import { TextInput } from '@astryxdesign/core/TextInput'
import { Button } from '@astryxdesign/core/Button'
import { Card } from '@astryxdesign/core/Card'
import { Icon } from '@astryxdesign/core/Icon'
import { Banner } from '@astryxdesign/core/Banner'
import { CubeIcon } from '@heroicons/react/24/outline'
import { pixelTheme } from '../../src/studio/pixel-theme.tsx'
import '../../src/fonts.css'

const params = new URLSearchParams(location.search)
const mode = params.get('mode') === 'dark' ? 'dark' : 'light'
const view = params.get('view') === 'login' ? 'login' : 'components'

function Components() {
  const [email, setEmail] = useState('')
  return (
    <VStack gap={4} padding={6} hAlign="stretch">
      <Heading level={2}>Components</Heading>
      <VStack gap={1} hAlign="start">
        <Text type="body">Body text</Text>
        <Text type="label">Label</Text>
        <Text type="supporting">Supporting</Text>
      </VStack>
      <HStack gap={2}>
        <Button label="Primary" variant="primary" />
        <Button label="Second" variant="secondary" />
      </HStack>
      <HStack gap={2}>
        <Button label="Ghost" variant="ghost" />
        <Button label="Delete" variant="destructive" />
      </HStack>
      <Card>
        <VStack gap={2} hAlign="start">
          <Heading level={3}>Card</Heading>
          <Text type="body">One item.</Text>
        </VStack>
      </Card>
      <TextInput label="Email" value={email} onChange={setEmail} placeholder="you@x.com" />
      <Banner status="info" title="Saved" description="It is live." />
      <Banner status="error" title="Sync failed" />
    </VStack>
  )
}

const pageStyle: CSSProperties = { minHeight: '100%', backgroundColor: 'var(--color-background-body)' }
const contentStyle: CSSProperties = { width: '100%', maxWidth: 400 }

// `astryx template login`, verbatim apart from the default export name.
function Login() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  return (
    <Center axis="both" padding={6} style={pageStyle}>
      <VStack gap={4} hAlign="center" style={contentStyle}>
        <VStack gap={2} hAlign="center">
          <Icon icon={CubeIcon} size="lg" />
          <Text type="body" weight="bold" size="lg">Product Inc.</Text>
        </VStack>
        <Card padding={8} width="100%">
          <VStack gap={4} hAlign="stretch">
            <VStack gap={1} hAlign="center">
              <Heading level={2}>Sign in</Heading>
              <Text type="body" color="secondary" size="sm">Enter your credentials to continue</Text>
            </VStack>
            <TextInput label="Email" value={email} onChange={setEmail} placeholder="you@example.com" type="email" size="lg" />
            <TextInput label="Password" value={password} onChange={setPassword} placeholder="Enter your password" type="password" size="lg" />
            <Button label="Sign in" variant="primary" size="lg" />
          </VStack>
        </Card>
      </VStack>
    </Center>
  )
}

createRoot(document.getElementById('root')!).render(
  <InternationalizationProvider locale="en" dir="ltr">
    <Theme theme={pixelTheme} mode={mode}>
      {view === 'login' ? <Login /> : <Components />}
    </Theme>
  </InternationalizationProvider>,
)
