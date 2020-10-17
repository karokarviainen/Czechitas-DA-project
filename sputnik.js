// Settings for the Web scraper:
// The function accepts a single argument: the "context" object.

async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery;
    const pageTitle = $('h1.headline').first().text();
    const pageAuthor = $('div.b-article__refs-author').text();
    const pageOpener = $('div.b-article__lead').text();
    const pageText = $('div.b-article__text');
    const pageDate = $('time.b-article__refs-date').text();
      
    // Return an object with the data extracted from the page.
    // It will be stored to the resulting dataset.
     return {
        url: context.request.url,
        pageTitle,
        pageAuthor,
        pageOpener,
        pageText,
        pageDate
        
    };
}