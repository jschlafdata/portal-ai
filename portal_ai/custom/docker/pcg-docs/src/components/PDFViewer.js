import React, { useState } from 'react';
import { Document, Page, pdfjs } from 'react-pdf';
import 'react-pdf/dist/esm/Page/AnnotationLayer.css';

// Specify the workerSrc to ensure PDF.js works properly in a web environment.
// This configuration should ideally be placed in your app's entry file or a high-level component to run once.
pdfjs.GlobalWorkerOptions.workerSrc = `//cdnjs.cloudflare.com/ajax/libs/pdf.js/${pdfjs.version}/pdf.worker.min.js`;

const PDFViewer = ({ file, width }) => {
  const [numPages, setNumPages] = useState(null);

  const onDocumentLoadSuccess = ({ numPages }) => {
    setNumPages(numPages);
  };

  return (
    <div>
      <Document
        file={file}
        onLoadSuccess={onDocumentLoadSuccess}
      >
        {Array.from({ length: numPages }, (_, index) => (
          // Set renderTextLayer to false to disable text layer rendering
          <Page key={`page_${index + 1}`} pageNumber={index + 1} width={width} renderTextLayer={false} />
        ))}
      </Document>
    </div>
  );
};

export default PDFViewer;
