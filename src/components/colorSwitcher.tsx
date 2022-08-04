/** @jsx jsx */

import * as React from "react"
import { Link } from "gatsby"
import {useThemeUI, Heading, Flex, NavLink, jsx, Box, Text} from 'theme-ui';
import { useColorMode } from 'theme-ui'

const ColorSwitcher = () => {
  const [colorMode, setColorMode] = useColorMode()
  console.log("Color=", colorMode);
  return (
    <header>
      <button
        onClick={(e) => {
          setColorMode(colorMode === 'light' ? 'dark' : 'light')
        }}
      >
        To {colorMode === 'light' ? 'Dark' : 'Light'}
      </button>
    </header>
  )
};

export default ColorSwitcher
