import React from 'react';

export default function AdmonitionIconDanger(props) {
  // Directly specify the emoji you want to display
  const emoji = '🔥'; // Dog emoji as an example

  return (
    <span {...props} style={{ fontSize: '24px' }}>{emoji}</span>
  );
}


// import React from 'react';
// import {remark} from 'remark';
// import emoji from 'remark-emoji';


// export default function AdmonitionIconDanger(props) {
 
//   const processor = remark().use(emoji);
//   const file = processor.process(':dog:');

//   return (
//     <svg viewBox="0 0 12 16" {...props}>
//       <path
//         fillRule="evenodd"
//         d={file}
//       />
//     </svg>
//   );
// }
