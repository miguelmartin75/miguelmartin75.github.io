import baseTheme from "@theme-ui/preset-tailwind"
import { alpha } from '@theme-ui/color'
import { merge } from "theme-ui"


export default merge(baseTheme, {
  config: {
    initialColorModeName: 'light',
  },
  space: [
    0,
    4,
    8,
    16,
    32,
    64,
    128,
    256,
    512
  ],
  fonts: {
    body: '"Helvetica", sans-serif',
    heading: 'inherit',
    monospace: 'Menlo, monospace'
  },
  fontSizes: [
    12,
    14,
    16,
    20,
    24,
    32,
    48,
    64,
    96
  ],
  fontWeights: {
    body: 400,
    heading: 700,
    bold: 700
  },
  lineHeights: {
    body: 1.5,
    heading: 1.125
  },
  colors: {
    text: '#2a2a2a',
    background: '#FCF8E8',
    primary: '#DF7861',
    secondary: '#76549A',
    muted: '#94B49F',
    modes: {
      dark: {
        text: '#EEEEEE',
        background: '#1B2430',
        primary: '#8ecdff',
        secondary: '#6c47cf',
        muted: '#8f8f8f',
      }
    }
  },
  styles: {
    pre: {
      fontFamily: 'monospace',
      color: 'inherit',
    },
    hr: {
      color: alpha('text', 0.5),
    },
    a: {
      color: 'primary',
      fill: 'text',
    }
  },
  links: {
    bold: {
      fontWeight: 'bold',
    },
    nav: {
      fontWeight: 'bold',
      color: 'inherit',
      textDecoration: 'none',
    }
  }
})
