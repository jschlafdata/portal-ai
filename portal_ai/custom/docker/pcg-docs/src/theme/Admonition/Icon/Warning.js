import React from 'react';

export default function AdmonitionIconCaution(props) {
  // Directly specify the emoji you want to display
  const emoji = '🚧'; // Dog emoji as an example

  return (
    <span {...props} style={{ fontSize: '24px' }}>{emoji}</span>
  );
}
