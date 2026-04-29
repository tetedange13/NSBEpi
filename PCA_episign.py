import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import plotly.express as px


# Read filtered TSV (only non fully '0' rows)
X = pd.read_csv("CUSTOM_hg38_episign/meth_matrix.tsv", sep="\t", index_col=0)

# Transpose and normalize
transposed_X = X.T  # Required
X_scaled = StandardScaler().fit_transform(transposed_X)

# Run PCA:
pca = PCA(n_components=2)
pcs = pca.fit_transform(X_scaled)

# Put results into a dataframe
pcs_df = pd.DataFrame(pcs).set_index(X.columns)
print(pcs_df.head())

# Plot PCA
fig = px.scatter(
	pcs_df,
	x=0,
	y=1,
	hover_data=[pcs_df.index]
)
fig.show()
