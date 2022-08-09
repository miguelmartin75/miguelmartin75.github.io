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
      const title = post.frontmatter.title || post.frontmatter.slug
      return (
        <li key={post.frontmatter.slug}>
            <article
              class-name="post-list-item"
              itemScope
              itemType="http://schema.org/Article"
            >
              <header>
                <pre sx={{display: 'inline'}}><time>{post.frontmatter.date}</time> </pre>
                <Link href={post.frontmatter.slug} itemProp="url">
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
    allMarkdownRemark(filter: {frontmatter: {state: {ne: "draft"}, slug: {regex: "$\/blog.*/g"}}}, sort: {fields: frontmatter___date, order: DESC}) {
      edges {
        node {
          frontmatter {
            title
            date
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

