// New settings for Cheerio scraper

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    const pageTitle = $('title').first().text().trim();
    const pageText = $('section.article-content p').text().trim();
    const pageDate = $('div.col-md-3').text().trim();
    const pageOpener = $('strong').first().text().trim();
    const pageAuthor = $('section.section-inarticle a strong').text().trim();
    const pageSection = $('a.tag').text().trim();

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