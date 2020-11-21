import pandas as pd

articles = pd.read_csv("in/tables/PROJECT_ALL_RUSSIA_FINAL.csv")

articles["pageText"] = articles["pageText"].str.replace("\xa0", " ")
articles["pageText"] = articles["pageText"].str.replace("[\d]{2,6} fotografií", "\n", regex=True)
articles["pageText"] = articles["pageText"].replace("[\s]{0,5}Související[\s]+[^\n]+[\s]{1,10}", "", regex=True)
articles["pageText"] = articles["pageText"].replace("[\n]Video[\:][\s]{0,1}.*[\s]+[\d]{1,2}[\:][\d]{1,2}[\s]+.*Video[\:]?.*", "", regex=True)
articles["pageText"] = articles["pageText"].replace("[\n][A-ZÁ-Ž].*[\:][\s]{0,1}.*[\s]+[\d]{1,2}[\:][\d]{1,2}[\s]+.*Video[\:].*", "", regex=True)
articles["pageText"] = articles["pageText"].replace("[\s]+[\d]{1,2}[\:][\d]{1,2}[\s]+.*Video[\:]?.*", "", regex=True)
articles["pageText"] = articles["pageText"].replace("[\n]Video[\:][\s]{0,1}.*[\s]+[\s]+.*Video[\:]?.*", "", regex=True)
articles["pageText"] = articles["pageText"].str.replace(".", ". ")
articles["pageText"] = articles["pageText"].str.replace(" {2,}", " ", regex=True)
articles["pageText"] = articles["pageText"].str.replace("[\s]{2,}", "\n", regex=True)
articles["pageText"] = articles["pageText"].str.strip()

articles.to_csv("out/tables/PROJECT_ALL_RUSSIA_FINAL_CLEAN.csv",index=False)