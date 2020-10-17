// Settings for Cheerio - Aktualne:

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    // for querying DOM elements and extracting data from them.
    const pageTitle = $('h1.article-title').first().text().trim();
    const pageAuthor = $('a.author__name').text().trim();
    const pageOpener = $('div.article__perex').first().text().trim();
    const pageText = $('div.article__content').text().trim();
    const pageDate = $('div.author__date').text().trim();
    const pageSection = $('a.header__menu__name').text().trim();

    // The "request" property contains various information about the web page loaded. 
    const url = request.url;
    
    // Use "log" object to print information to actor log.
    log.info('Aktualne', { url, pageTitle });

    // Return an object with the data extracted from the page.
    // It will be stored to the resulting dataset.
    return {
        url,
        pageTitle,
        pageAuthor,
        pageOpener,
        pageText,
        pageDate,
        pageSection
    };
}