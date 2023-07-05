/** @jsx jsx */

import * as React from "react"
import { graphql } from "gatsby"
import Layout from '../components/layout';
import {Container, Text, Link, jsx} from 'theme-ui';

import WebGl from '../components/webgl';
import main from "../toy.js";

// TODO
//import {Helmet} from "react-helmet";

const IndexPage = ({data}) => {
  const posts = data.allMarkdownRemark.edges

  const postList = posts.map(temp => {
      const post = temp.node
      // const slug = post.frontmatter.slug || post.fields.slug
      let slug = post.frontmatter.slug
      if(post.fields) {
        slug = post.frontmatter.slug || post.fields.slug
      }
      const title = post.frontmatter.title || slug
      return (
        <li key={slug}>
            <article
              class-name="post-list-item"
              itemScope
              itemType="http://schema.org/Article"
            >
              <header>
                <pre sx={{display: 'inline'}}><time>{post.frontmatter.date}</time> </pre>
                <Link href={slug} itemProp="url">
                  <span itemProp="headline">{title}</span>
                </Link>
              </header>
              <section>
                <Text
                  dangerouslySetInnerHTML={{
                    __html: post.description || post.excerpt,
                  }}
                  itemProp="description"
                />
              </section>
            </article>
        </li>
      )
  });

  return (
    <Layout>
      <title>Miguel's Blog</title>
      <Container>
        <ul>{postList}</ul>
      </Container>
      <WebGl func={main} sx={{position: 'absolute', top: 0, left: 0}}></WebGl>
    </Layout>
  )
}

export default IndexPage

export const pageQuery = graphql`
  query AllPosts {
    allMarkdownRemark(filter: {frontmatter: {state: {eq: "publish"}}}, sort: {frontmatter: {date: DESC}}) {
      edges {
        node {
          frontmatter {
            title
            date
            slug
            source
            code
          }
          fields {
            slug
          }
          children {
            id
          }
        }
      }
    }
  }
`

