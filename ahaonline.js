// The first crawler we created using one of the crawlers from project Terror or clickbait? as inspiration (https://medium.com/@j.hoskova/terror-or-clickbait-501b020a9bc5). We didn't use this crawler in our project.

// The function accepts a single argument: the "context" object.

async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery;
    const pageTitle = $('title').first().text();
    const date = $('#article .articleMeta .dateTime').text();
    const perex = $('.perex').text();
    const text = $('#article .body').text();
    

    // Print some information to actor log
    context.log.info(`URL: ${context.request.url}, TITLE: ${pageTitle}`);
  
    // Return an object with the data extracted from the page.
    // It will be stored to the resulting dataset.
     return {
        url: context.request.url,
        pageTitle,
        date,
        perex,
        text
        
    };
}

