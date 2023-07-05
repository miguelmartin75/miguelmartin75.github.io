/** @jsx jsx */

import * as React from "react"
import { graphql } from "gatsby"
import Layout from '../components/layout';
import {Container, Text, Link, jsx} from 'theme-ui';

import WebGl from '../components/webgl';
import main from "../toy.js";

// TODO
//import {Helmet} from "react-helmet";

const NotePage = ({data}) => {
  let notes = data.allMarkdownRemark.edges

  const notesList = notes.map(temp => {
      const post = temp.node
      let title = post.frontmatter.title || post.frontmatter.slug
      let slug = post.frontmatter.slug
      if(post.fields) {
        title = title || post.fields.slug
        slug = slug || post.fields.slug
      }

      // TODO changeme
      let extra = "";
      if (post.frontmatter.tags) {
        extra += ` | ${post.frontmatter.tags}`
      } else {
        extra += " | []"
      }

      if (post.frontmatter.state) {
        extra += ` | ${post.frontmatter.state}`
      } else {
        extra += " | no state"
      }

      return (
        <li key={slug}>
            <article
              class-name="post-list-item"
              itemScope
              itemType="http://schema.org/Article"
            >
              <header>
                <Link href={slug} itemProp="url">
                  <span itemProp="headline">{title}</span>
                </Link> {extra}
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
      <title>Miguel's Notes</title>
      <Container>
        <ul>{notesList}</ul>
      </Container>
      <WebGl func={main} sx={{position: 'absolute', top: 0, left: 0}}></WebGl>
    </Layout>
  )
}

export default NotePage

export const pageQuery = graphql`
query Notes {
  allMarkdownRemark(
    filter: {frontmatter: {state: {eq: null}}},
    sort: {frontmatter: {title: ASC}}
	) {
    edges {
      node {
        frontmatter {
          title
          date
          slug
          tags
          state
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
