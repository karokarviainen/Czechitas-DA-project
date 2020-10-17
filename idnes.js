// New settings for Cheerio scraper

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    // for querying DOM elements and extracting data from them.
    const pageTitle = $('title').first().text().trim();
    const pageText = $('div#art-text.text').text().trim();
    const pageDate = $('span.time-date').text().trim();
    const pageOpener = $('div.opener').text().trim();
    const pageAuthor = $('div.authors').text().trim();
    const pageSection = $('div.portal-g2a h3').text().trim();


    // Return an object with the data extracted from the page.
    // It will be stored to the resulting dataset.
    return {
        pageSection,
        pageText,
        pageOpener,
        pageDate,
        pageAuthor,
        pageTitle,
        url: context.request.url
    };
}