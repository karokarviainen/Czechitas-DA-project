// Settings for Cheerio scraper:

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    // for querying DOM elements and extracting data from them.
    const pageTitle = $('h1.mt--0').first().text().trim();
    const pageAuthor = $('p.meta.meta--right.meta--big > strong').text().trim();
    const pageOpener = $('p.text-bold--m.text-md--m.text-lg').first().text().trim();
    const pageText = $('div.b-detail > p').text().trim();
    const pageDate = $('time').text().trim();
    const pageSection = $('div.row.row--article.hide--m').text().trim(); 



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