/** @jsx jsx */

import * as React from "react"
import { Link } from "gatsby"
import {IconButton, Heading, Flex, NavLink, jsx, Box, Text} from 'theme-ui';
import ColorSwitcher from "./colorSwitcher";

import WebGl from '../components/webgl';
import main from "../toy.js";

const Header = () => (
<header
  sx={{
    variant: 'styles.header',
    mb: 3
  }}>
  <Flex as="nav">
    <WebGl func={main} sx={{
      position: 'absolute',
      top: 0,
      left: 0,
    }}></WebGl>
    <NavLink href="/" p={2}>
      blog
    </NavLink>
    <NavLink href="/notes" p={2}>
      notes
    </NavLink>
    <div sx={{ mx: 'auto' }} />

    <div
    sx={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    }}>
    <Box sx={{        
        px: 2,
        py: 0,
        textTransform: 'lowercase',
        color: 'primary',}}>
      <Heading>miguel</Heading>
    </Box>
    <ColorSwitcher></ColorSwitcher>
    </div>
  </Flex>
</header>
)
export default Header
