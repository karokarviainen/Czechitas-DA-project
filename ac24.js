// Settings for Cheerio scraper:

async function pageFunction(context) {
    const { $, request, log } = context;

    // The "$" property contains the Cheerio object which is useful
    // for querying DOM elements and extracting data from them.
    const pageTitle = $('span.header-title').first().text().trim();
    //const pageAuthor = $('div.ac24-portlet-badge').text().trim();
    const pageOpener = $('div.ac24-summary').first().text().trim();
    const pageText = $('div.ac24-article-content').text().trim();
    const pageDate = $('span.spaced.svg-icon').first().text().trim();
    //const pageSection = $('div.ac24-portlet-badge').text().trim();



    // Return an object with the data extracted from the page.
    // It will be stored to the resulting dataset.
    return {
        url: context.request.url,
        pageTitle,
        //pageAuthor,
        pageOpener,
        pageText,
        pageDate,
        //pageSection
    };
}

// AC24_problemy
// Nejde mi dostat do dat autora a rubriku.
// Autor by asi nebyl tak velký problém, protože stejně všude mají "Redakce AC24".
// Rubrika je trochu průšvih, protože ji nemají uvedenou v URL.


// Zkoušela jsem různé tagy. Třeba tyhle. Ale nic nešlo.

//     const pageAuthor = $('div.ac24-portlet-badge').text().trim();
//     const pageSection = $('div.ac24-portlet-badge').text().trim();