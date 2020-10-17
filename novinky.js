// The function accepts a single argument: the "context" object.

async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery; 
    const pageTitle = $('h1.d_r.d_s').first().text().trim();
    const pageAuthor = $('div.f_aH').text().trim();
    const pageOpener = $('p.d_c-').first().text().trim();
    const pageText = $('div.f_cZ').text().trim();
    const pageDate = $('span.atm-date-formatted').text().trim();
    const pageSection = $('div.g_hA a span').first().text().trim(); 
   
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