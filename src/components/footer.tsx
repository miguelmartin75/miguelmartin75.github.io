import * as React from "react"
import { Link } from "gatsby"
import {Button, NavLink, jsx, Text} from 'theme-ui';

const Footer = () => (
  <footer
    sx={{
      display: 'flex',
      flexWrap: 'wrap',
      alignItems: 'center',
      p: 2,
      variant: 'styles.footer',
    }}>
    <Link to="/" sx={{ variant: 'styles.navlink', p: 2 }}>
      Github TODO icon
    </Link>
    <Link to="/" sx={{ variant: 'styles.navlink', p: 2 }}>
      LinkedIn TODO icon
    </Link>
  </footer>
)

export default Footer
