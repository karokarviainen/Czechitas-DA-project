// Settings for Cheerio scraper:

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    // for querying DOM elements and extracting data from them.
    const pageTitle = $('span.header-title').first().text().trim();
    const pageAuthor = $('span.spaced.svg-icon:eq(1)').text().trim();
    const pageOpener = $('div.ac24-summary').first().text().trim();
    const pageText = $('div.ac24-article-content').text().trim();
    const pageDate = $('span.spaced.svg-icon').first().text().trim();
    const pageSection = $('span.spaced.svg-icon').text().trim();



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