/** @jsx jsx */

import * as React from "react"
import { Link, IconButton } from "gatsby"
import {useThemeUI, Heading, Flex, NavLink, jsx, Box, Text} from 'theme-ui';
import { useColorMode } from 'theme-ui'

import { HiMoon, HiSun } from "react-icons/hi";

const ColorSwitcher = () => {
  const [colorMode, setColorMode] = useColorMode()
  if(colorMode === 'light') {
    return (
      <header>
        <HiMoon sx={{transform: "scale(2.0)", mt: 0, ml: 10, mr: 0, mb: 0}}
          onClick={(e) => {
            setColorMode(colorMode === 'light' ? 'dark' : 'light')
          }}
        >
          To {colorMode === 'light' ? 'Dark' : 'Light'}
        </HiMoon>
      </header>
    )
  } else {
    return (
      <header>
        <HiSun sx={{transform: "scale(2.0)", mt: 0, ml: 10, mr: 0, mb: 0}}
          onClick={(e) => {
            setColorMode(colorMode === 'light' ? 'dark' : 'light')
          }}
        >
          To {colorMode === 'light' ? 'Dark' : 'Light'}
        </HiSun>
      </header>
    )
  }
};

export default ColorSwitcher
