import React, { useState } from 'react';
import CodeBlock from '@theme/CodeBlock';


function Folder({ name, children, highlightedPaths, comment, depth = 0 }) {
  const isHighlighted = highlightedPaths.includes(name);
  const folderStyle = {
    fontWeight: isHighlighted ? 'bold' : 'normal',
    color: isHighlighted ? '#ff0000' : '#000000', // Change color based on highlighting
  };
  const dashes = Array.from({ length: depth * 4 }, () => ' ').join('');

  return (
    <div style={{ marginLeft: 20 }}>
      <div style={folderStyle}>
        {dashes}
        {depth > 0 && '├── '}
        {name} {comment && `[${comment}]`} {/* Render comment if available */}
      </div>
      {children && (
        <div style={{ marginLeft: 20 }}>
          {children.map((child, index) => (
            <Folder
              key={index}
              name={child.name}
              children={child.children}
              highlightedPaths={highlightedPaths}
              comment={child.comment} // Pass comment down to child folders
              depth={depth + 1} // Increase depth for child folders
            />
          ))}
        </div>
      )}
    </div>
  );
}

function FolderTree({ folders, highlightedPaths }) {
  return (
    <div>
      {folders.map((folder, index) => (
        <Folder
          key={index}
          name={folder.name}
          children={folder.children}
          highlightedPaths={highlightedPaths}
          comment={folder.comment} // Pass comment to the root folders
        />
      ))}
    </div>
  );
}

function StandardTree() {
  // Example folder structure with comments
  const folders = [
    {
      name: 'dbx_code',
      comment: 'Top-level directory for code related to Dropbox integration',
      children: [
        {
          name: 'global_python_modules',
          comment: 'Python modules shared across multiple projects',
          children: [
            { name: 'catalog_utilities', comment: 'Utilities for working with catalog data' },
            { name: 'notebook_executors', comment: 'Executors for running notebooks as scripts' },
          ],
        },
        {
          name: 'pipelines',
          comment: 'Data pipelines for various projects',
          children: [
            {
              name: 'concert_finder',
              comment: 'Pipeline for finding concerts in a given location',
              children: [
                { name: 'get_current_notebook_paths.py', comment: 'Script to get current notebook paths' },
                {
                  name: 'jobs',
                  comment: 'YAML configurations for pipeline jobs',
                  children: [
                    { name: 'scrape_music_venues.yaml', comment: 'Configuration for scraping music venues' },
                    { name: 'scrape_music_venues.dbc', comment: 'Notebook file for scraping music venues' },
                  ],
                },
              ],
            },
            { name: 'pipeline_settings.yaml', comment: 'Settings for pipeline execution' },
            { name: 'scrape_music_venues.params.yaml', comment: 'Parameter file for scraping music venues' },
          ],
        },
      ],
    },
  ];

  const highlightedPaths = ['dbx_code', 'pipelines', 'concert_finder']; // Example highlighted paths

  return (
    <div>
      <CodeBlock
        language="jsx"
        title="/src/components/HelloCodeTitle.js"
        showLineNumbers>
        {<FolderTree folders={folders} highlightedPaths={highlightedPaths} />}
      </CodeBlock>
    </div>
  );
}


export default StandardTree;