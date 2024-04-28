import React from 'react';
// Import the original mapper
import MDXComponents from '@theme-original/MDXComponents';
import CollapsibleTree from '@site/src/components/CollapsibleTree';
import StandardTree from '@site/src/components/StandardTree';

export default {
  // Re-use the default mapping
  ...MDXComponents,
  // Map the "<Highlight>" tag to our Highlight component
  // `Highlight` will receive all props that were passed to `<Highlight>` in MDX
  CollapsibleTree,
  StandardTree,
};