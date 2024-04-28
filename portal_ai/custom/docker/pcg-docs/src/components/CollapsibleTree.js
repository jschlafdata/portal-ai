import React, { useState } from 'react';

// A simple recursive component to render the tree
const TreeNode = ({ node }) => {
  const [isOpen, setIsOpen] = useState(false);
  const hasChildren = node.children && node.children.length > 0;

  return (
    <div style={{ marginLeft: 20 }}>
      <div onClick={() => setIsOpen(!isOpen)} style={{ cursor: 'pointer' }}>
        {hasChildren ? (isOpen ? '📂' : '📁') : '📄'} {node.name}
      </div>
      {isOpen && hasChildren && (
        <div style={{ marginLeft: 10 }}>
          {node.children.map((child, index) => (
            <TreeNode key={index} node={child} />
          ))}
        </div>
      )}
    </div>
  );
};

const CollapsibleTree = ({ data }) => {
  return <TreeNode node={data} />;
};

export default CollapsibleTree;
