# Get quotes from the PROJECT_ALL_RUSSIA_FINAL_CLEAN table. This script contains the final regex-

import pandas as pd

articles = pd.read_csv("in/tables/PROJECT_ALL_RUSSIA_FINAL_CLEAN.csv")

articles["cit"] = articles["pageText"].str.findall(r'[\.]?[A-ZÁ-Ž][^\.]+[\:][\s]?[^\.][\s]?["|„|”|“]{1}.*?[^\,][\.]?["|“|”]{1}[\.]?|["|„|”|“]{1}[A-ZÁ-Ž].*?["|“|”]{1}.*?[\.]{1}')

new_articles = articles.filter(["ID", "pageDate", "cit", "url", "source"])

new_articles = new_articles.explode("cit")

new_articles = new_articles.dropna()

new_articles.to_csv("out/tables/2020_11_27_PROJECT_QUOTES.csv",index=False)