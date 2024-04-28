// In your component or page that includes the PDFViewer
import React, { lazy, Suspense, useEffect, useState } from 'react';

const PDFViewerLazy = lazy(() => import('./PDFViewer')); // Adjust the import path as necessary

const PDFViewerWrapper = (props) => {
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(typeof window !== 'undefined');
  }, []);

  return (
    <div>
      {isClient && (
        <Suspense fallback={<div>Loading PDF...</div>}>
          <PDFViewerLazy {...props} />
        </Suspense>
      )}
    </div>
  );
};

export default PDFViewerWrapper;
