// Settings for Web scraper:

// The function accepts a single argument: the "context" object.

async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery; 
    
    const pageTitle = $('h1.mt--0').first().text().trim();
    const pageAuthor = $('p.meta.meta--right.meta--big > strong').text().trim();
    const pageOpener = $('p.text-bold--m.text-md--m.text-lg').first().text().trim();
    const pageText = $('p').text().trim();
    const pageDate = $('time').text().trim();
    const pageSection = $('#breadcrumb').text(); 
   
    // Return an object with the data extracted from the page.
    // It will be stored to the resulting dataset.
     return {
        url: context.request.url,
        pageTitle,
        pageAuthor,
        pageOpener,
        pageText,
        pageDate,
        pageSection
        
    };
}