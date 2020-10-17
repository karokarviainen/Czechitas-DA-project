// Novinky: Settings for the Cheerio scraper:

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    // for querying DOM elements and extracting data from them.
    const pageTitle = $('h1.d_r.d_s').first().text().trim();
    const pageAuthor = $('div.f_aH').text().trim();
    const pageOpener = $('p.d_c-').first().text().trim();
    const pageText = $('div.f_cZ').text().trim();
    const pageDate = $('span.atm-date-formatted').text().trim();
    const pageSection = $('div.g_hA a span').first().text().trim();

    // The "request" property contains various information about the web page loaded. 
    const url = request.url;
    
    
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