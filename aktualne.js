// Settings for Web Scraper - Aktualne:

// The function accepts a single argument: the "context" object.
// For a complete list of its properties and functions,
// see https://apify.com/apify/web-scraper#page-function 
async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery; 
    
    const pageTitle = $('h1.article-title').first().text().trim();
    const pageAuthor = $('a.author__name').text().trim();
    const pageOpener = $('div.article__perex').first().text().trim();
    const pageText = $('div.article__content').text().trim();
    const pageDate = $('div.author__date').text().trim();
    const pageSection = $('a.header__menu__name').text().trim(); 
   
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