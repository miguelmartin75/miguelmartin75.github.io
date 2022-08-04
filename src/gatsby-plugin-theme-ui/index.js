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
    body: '"Raleway", sans-serif',
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
  //colors: {
  //  text: '#2a2a2a',
  //  background: '#f6f6f6',
  //  primary: '#8ecdff',
  //  secondary: '#6c47cf',
  //  muted: '#f9f9f9',
  //  modes: {
  //    dark: {
  //      text: 'blue',
  //      background: '#000000',
  //      primary: '#8ecdff',
  //      secondary: '#6c47cf',
  //      muted: '#f9f9f9'
  //    }
  //  }
  //},
  styles: {
    pre: {
      fontFamily: 'monospace',
    },
    hr: {
      color: alpha('text', 0.5),
    }
  }
})
