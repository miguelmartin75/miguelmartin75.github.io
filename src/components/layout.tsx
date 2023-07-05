/** @jsx jsx */

import * as React from "react"
import { Global } from "@emotion/react"
import Footer from '../components/footer';
import Header from '../components/header';
import { 
  Theme,
  Container,
  Box,
  jsx,
  Link,
  Text,
  Flex,
  NavLink,
  Progress,
} from "theme-ui"

export interface LayoutProps  { 
   children: React.ReactNode
}

const Layout = (props: LayoutProps) => (
  // <Theme.root>
    <Container sx={{
        maxWidth: 900,
        mx: 'auto',
        px: 3,
        py: 4,
      }}>
      <Header></Header>
      <main
        sx={{
          px: 3,
          flex: '1 1 auto',
        }}>
        {props.children}
      </main>
    </Container>

  // </Theme.root>
);

export default Layout
