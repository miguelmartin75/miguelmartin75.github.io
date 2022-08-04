/** @jsx jsx */

import * as React from "react"
import { Link } from "gatsby"
import {IconButton, Heading, Flex, NavLink, jsx, Box, Text} from 'theme-ui';
import ColorSwitcher from "./colorSwitcher";

const Header = () => (
<header
  sx={{
    variant: 'styles.header',
    mb: 3
  }}>
  <Flex as="nav">
    <NavLink href="/" p={3}>
      home
    </NavLink>
    <div sx={{ mx: 'auto' }} />

    <div
    sx={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    }}>
    <Box sx={{        
        px: 3,
        py: 1,
        textTransform: 'lowercase',
        color: 'primary',}}>
      <Heading>miguel's blog</Heading>
    </Box>
    </div>
    <div sx={{ mx: 'auto' }} />
    <NavLink href="/todo" p={3}>
      contact
    </NavLink>
    <ColorSwitcher></ColorSwitcher>
  </Flex>
</header>
)
export default Header
