import type { GatsbyConfig } from "gatsby";
import MonacoWebpackPlugin from 'monaco-editor-webpack-plugin';

const config: GatsbyConfig = {
  flags: {
    DEV_SSR: true
  },
  siteMetadata: {
    title: `Miguel's Blog`,
    siteUrl: `https://miguel-martin.com/`
  },
  plugins: [
  {
    resolve: `gatsby-plugin-theme-ui`,
    options: {
      preset: require('./src/gatsby-plugin-theme-ui'),
    },
  },
  {
    resolve: 'gatsby-plugin-google-analytics',
    options: {
      "trackingId": "UA-43056617-3"
    }
  }, "gatsby-plugin-image", "gatsby-plugin-sitemap", {
    resolve: 'gatsby-plugin-manifest',
    options: {
      "icon": "static/images/icon.png"
    }
  }, "gatsby-plugin-mdx", "gatsby-plugin-sharp", "gatsby-transformer-sharp", {
    resolve: 'gatsby-source-filesystem',
    options: {
      "name": "images",
      "path": "./static/images/"
    },
    __key: "images"
  }, 
  {
    resolve: 'gatsby-source-filesystem',
    options: {
      "name": "pages",
      "path": "./src/pages/"
    },
    __key: "pages"
  }, {
    resolve: 'gatsby-source-filesystem',
    options: {
      "name": "notes",
      "path": "./notes"
    },
    __key: "notes"
  }, {
    resolve: 'gatsby-source-filesystem',
    options: {
      "name": "papers",
      "path": "./notes/papers"
    },
    __key: "papers"
  }, {
    resolve: 'gatsby-source-filesystem',
    options: {
      "name": "static",
      "path": "./static/"
    },
    __key: "static"
  }, {
    resolve: 'gatsby-source-filesystem',
    options: {
      "name": "pages",
      "path": "./posts"
    },
    __key: "markdownPages"
  }, 
  {
    resolve: `gatsby-transformer-remark`,
    options: {
      // Footnotes mode (default: true)
      footnotes: true,
      // GitHub Flavored Markdown mode (default: true)
      gfm: true,
      // Plugins configs
      plugins: [
        `gatsby-remark-autolink-headers`,
        {
          resolve: `gatsby-remark-katex`,
          options: {
            // Add any KaTeX options from https://github.com/KaTeX/KaTeX/blob/master/docs/options.md here
            strict: `ignore`
          }
        },
      ],
    },
  },
  ]
};

exports.onCreateWebpackConfig = ({
  stage,
  rules,
  loaders,
  plugins,
  actions,
}) => {
  actions.setWebpackConfig({
    module: {
      rules: [
        {
          test: /\.less$/,
          use: [
            // You don't need to add the matching ExtractText plugin
            // because gatsby already includes it and makes sure it's only
            // run at the appropriate stages, e.g. not in development
            loaders.miniCssExtract(),
            loaders.css({ importLoaders: 1 }),
            // the postcss loader comes with some nice defaults
            // including autoprefixer for our configured browsers
            loaders.postcss(),
            `less-loader`,
          ],
        },
      ],
    },
    plugins: [
      plugins.define({
        __DEVELOPMENT__: stage === `develop` || stage === `develop-html`,
      }),
      new MonacoWebpackPlugin({
        // available options are documented at https://github.com/Microsoft/monaco-editor-webpack-plugin#options
        languages: ['json']
      }),
    ],
  })
}

export default config;
