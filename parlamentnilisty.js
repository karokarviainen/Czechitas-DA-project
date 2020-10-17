// The function accepts a single argument: the "context" object.

async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery;
    const pageTitle = $('title').first().text().trim();
    const pageText = $('section.article-content').text().trim();
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