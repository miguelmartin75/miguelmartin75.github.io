/** @jsx jsx */

import rehypeReact from "rehype-react"
import React from "react"
import { graphql } from "gatsby"
import { Themed, Divider, Box, Link, jsx } from "theme-ui"
import Layout from '../components/layout';
import CellBlock from '../components/cellBlock';
import Utterances from "utterances-react"

import 'katex/dist/katex.min.css';


export default function Template({
  data, // this prop will be injected by the GraphQL query below.
}) {
  const { markdownRemark } = data // data.markdownRemark holds your post data
  const { frontmatter, htmlAst } = markdownRemark

  const renderAst = new rehypeReact({
    createElement: React.createElement,
    components: {
      a: Link,
      code: CellBlock,
    },
  }).Compiler

  const issueName = frontmatter.slug
  console.log(issueName)

  return (
    <Layout>
      <div className="blog-post">
        <Box>
          <Themed.h1 sx={{m: 0}}>{frontmatter.title}</Themed.h1>
          <pre sx={{m: 0, p: 0, mt: 10}}><time>{frontmatter.date}</time></pre>
        </Box>
        <Divider></Divider>
        <div className="blog-post-content">
          { renderAst(htmlAst) }
        </div>
        <Utterances
          repo="miguelmartin/miguelmartin75.github.io"
          issueTerm={issueName}
          label=""
          theme="github-light"
          crossorigin="anonymous"
          async={false}
          style={`
          & .utterances {
            max-width: 950px;
          }
        `}
        />
      </div>
    </Layout>
  )
}

export const pageQuery = graphql`
  query($id: String!) {
    markdownRemark(id: { eq: $id }) {
      htmlAst
      frontmatter {
        date(formatString: "MMMM DD, YYYY")
        slug
        title
      }
    }
  }
`
