# This Python transformation will have two tables as an output. Both tables will be made directly from the 2020-11-27-QUOTES_FINAL table. One table will contain the quotation itself and the other one will contain the part outside of the quotation marks. These two tables will be used in the Geneea analysis so we can be more sure who is the speaker and who is mentioned.

import pandas as pd
df = pd.read_csv("in/tables/2020_11_27_PROJECT_QUOTES_FINAL.csv")

df["in_quote"] = df["quote"].str.findall(r'["|„|”|“]{1}.*?["|“|”]{1}')
df["out_quote"] = df["quote"].replace('["|„|”|“]{1}.*?["|“|”]{1}', '', regex=True)

df_in = df.filter(items=["quote_ID", "article_ID", "quote_index", "pageDate", "in_quote", "url", "source"])

df_out = df.filter(items=["quote_ID", "article_ID", "quote_index", "pageDate", "out_quote", "url", "source"])

df_in.to_csv("out/tables/2020_11_27_PROJECT_QUOTES_FINAL_INSIDE.csv",index=False)
df_out.to_csv("out/tables/2020_11_27_PROJECT_QUOTES_FINAL_OUTSIDE.csv",index=False)