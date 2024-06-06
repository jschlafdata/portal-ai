// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

import {themes as prismThemes} from 'prism-react-renderer';

const webpack = require('webpack');

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Schlafdata - Own your data stack.',
  tagline: 'Documentaion for end to end Cloud Data Systems',
  favicon: 'img/portal-main-docs.png',
  // Set the production url of your site here
  url: 'https://docs.ai-portal.zone',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: '/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'schlafdata', // Usually your GitHub org/user name.
  projectName: 'global system docs', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },
  plugins: [
    'docusaurus-plugin-sass',
    // @docusaurus/plugin-google-analytics (Not necessary because it automatically gets added)
  ],
  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          routeBasePath: '/',
          // admonitions: {
          //   keywords: ['my-custom-admonition'],
          //   extendDefaults: true,
          // },
          remarkPlugins: [
            [require('./node_modules/remark-emoji', ), { sync: true },],
          ],
          editUrl:
            'https://github.com/facebook/docusaurus/tree/main/packages/create-docusaurus/templates/shared/',
        },
        theme: {
          customCss: [require.resolve('./src/css/custom.scss')],
          // customCss: './src/css/custom.css',
        },
      }),
    ],
  ],
  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/docusaurus-social-card.jpg',
      navbar: {
        title: 'Portal-Ai Docs',
        logo: {
          alt: 'My Site Logo',
          src: 'img/portal-main-docs.png',
        },
        items: [
          {
            type: 'docSidebar',
            sidebarId: 'tutorialSidebar',
            position: 'left',
            label: 'Documentaion',
          },
          {
            href: 'https://github.com/jschlafdata/portal-ai',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      prism: {
        theme: prismThemes.oneLight,
        additionalLanguages: ['hcl', 
                              'bash'],
        defaultLanguage: 'python',
        magicComments: [
          {
            className: 'theme-code-block-highlighted-line',
            line: 'highlight-next-line',
            block: {start: 'highlight-start', end: 'highlight-end'},
          },
          {
            className: 'code-block-error-message',
            line: 'highlight-next-line-error-message',
          },
          {
            className: 'code-block-info-line',
            line: 'highlight-next-line-info',
          },
          {
            className: 'code-block-underline',
            line: 'underline-next-line',
          },
        ],
      },
    }),
};

export default config;
