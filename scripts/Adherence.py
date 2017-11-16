import numpy as np
#import matplotlib.pyplot as plt
from sklearn import preprocessing, cross_validation, neighbors
import pandas as pd

def main():
    df = pd.read_csv("./csvs/features.csv",usecols=[1, 2, 3])
    df.replace('?', -99999, inplace=True)
    #df.drop([Timestamp], 1, inplace = True)
    df["id"] = df.index + 1

    df['Does your work require sitting or moving more ?'] = df['Does your work require sitting or moving more ?'].map({'Mostly moving (Involves movement more than 3days per week)': 3, 'Moderate (involves both sitting and moving)': 2, 'Mostly sitting (Involves movement less than 30 minutes per week)':1})

    def f(row):
        if row['Does your work require sitting or moving more ?'] == 3:
            val = 3
        elif row['Does your work require sitting or moving more ?'] == 2:
            val = 2
        else:
            val = 1
        return val

    df['Adherence'] = df.apply(f, axis=1)

    df = df.fillna(0)

    x = np.array(df.drop(['Adherence'],1))
    y = np.array(df['Adherence'])
    x_train, x_test, y_train, y_test = cross_validation.train_test_split(x,y,test_size=0.2)
    clf = neighbors.KNeighborsClassifier()

    clf.fit(x_train, y_train)

    accuracy = clf.score(x_test,y_test)
    prediction = clf.predict(x)

    # Pass to CoachAI
    df2 = df = pd.read_csv("./csvs/features.csv")
    df2['prediction'] = prediction
    def g(row):
        if row['prediction'] == 3:
            val = "HIGH"
        elif row['prediction'] == 2:
            val = "MEDIUM"
        else:
            val = "LOW"
        return val
    df2['prediction'] = df.apply(g, axis=1)

    df2.to_csv("./csvs/result.csv", sep=',')


if __name__ == '__main__':
    main()
