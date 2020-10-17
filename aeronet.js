// Aeronet was the only website we scraped only using Apify's Web scraper (other websites were scraped with Cheerio scraper)

// Settings for Web Scraper - Aeronet:

// The function accepts a single argument: the "context" object.

async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery;
    const pageTitle = $('h1.entry-title').first().text().trim();
    const pageText = $('div.pf-content').text().trim();
    const pageDate = $('time.entry-date.updated').first().text().trim();
    const pageOpener = $('div.pf-content > h4').text().trim();
    const pageAuthor = $('').text().trim();
    const pageSection = $('li.entry-category').text().trim();
     

    // Print some information to actor log
    context.log.info(`URL: ${context.request.url}, TITLE: ${pageTitle}`);
  
    // Return an object with the data extracted from the page.
    // It will be stored to the resulting dataset.
     return {
        url: context.request.url,
        pageTitle,
        pageText,
        pageDate,
        pageOpener,
        pageAuthor,
        pageSection
    };
}