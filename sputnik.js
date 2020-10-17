// Settings for the Cheerio scraper:

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    // for querying DOM elements and extracting data from them.
    const pageTitle = $('title').first().text().trim();
    const pageText = $('div.b-article__text p').text().trim();
    const pageDate = $('time.b-article__refs-date').text().trim();
    const pageOpener = $('div.b-article__lead p').text().trim();
    const pageAuthor = $('div.b-article__refs-author a').text().trim();
    const pageSection = $('a.b-article__refs-rubric').text().trim();


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