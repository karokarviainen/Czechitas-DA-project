// Settings for Web scraper:

// The function accepts a single argument: the "context" object.

async function pageFunction(context) {
    // jQuery is handy for finding DOM elements and extracting data from them.
    // To use it, make sure to enable the "Inject jQuery" option.
    const $ = context.jQuery; 
    
    const pageTitle = $('h1.mt--0').first().text().trim();
    const pageAuthor = $('p.meta.meta--right.meta--big > strong').text().trim();
    const pageOpener = $('p.text-bold--m.text-md--m.text-lg').first().text().trim();
    const pageText = $('p').text().trim();
    const pageDate = $('time').text().trim();
    const pageSection = $('#breadcrumb').text(); 
   
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

// Problemy:

// - PageSection: 
// const pageSection = $('#breadcrumb').text();
// Tahle bere jen "Kde se nacházíte"
// Ale neřešila bych to a vzala pak z URL.

// - PageText:
// const pageText = $('p').text().trim();
// Asi to docela funguje, text tam je. Ale nevím, ten tag je nějak moc malej :-).
// A taky teda to bere text včetně perexu.
// Takže perex je pak ve sloupci PageOpener a ještě jednou v textu.