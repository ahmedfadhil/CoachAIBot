import numpy as np
#import matplotlib.pyplot as plt
from sklearn import preprocessing, cross_validation, neighbors
import pandas as pd
from sklearn import svm

def main():
    df1 = pd.read_csv("./csvs/Active.csv",usecols=[0, 1, 2])
    df1.replace('?', -99999, inplace=True)
    #df.drop([Timestamp], 1, inplace = True)


    df2 = pd.read_csv("./csvs/Moderate.csv",usecols=[0, 1, 2])
    df2.replace('?', -99999, inplace=True)


    df0 = pd.read_csv("./csvs/features.csv", usecols=[1, 2, 3])
    df0.replace('?', -99999, inplace=True)


    frames = [df1, df2,df0]
    df = pd.concat(frames)
    df["id"] = df.index + 1


    #print (df[:5])
    df['Does your work require sitting or moving more ?'] = df['Does your work require sitting or moving more ?'].map({'Mostly moving (Involves movement more than 3days per week)': 3, 'Moderate (involves both sitting and moving)': 2, 'Mostly sitting (Involves movement less than 30 minutes per week)':1})

    print (df[:5])

    def f(row):
        if row['Does your work require sitting or moving more ?'] == 3:
            val = 3
        elif row['Does your work require sitting or moving more ?'] == 2:
            val = 2
        else:
            val = 1
        return val

    df['Adherence'] = df.apply(f, axis=1)

    df = df.fillna(2)

    x = np.array(df.drop(['Adherence'],1))
    y = np.array(df['Adherence'])
    x_train, x_test, y_train, y_test = cross_validation.train_test_split(x,y,test_size=0.2)
    #clf = neighbors.KNeighborsClassifier()
    clf = svm.SVC( C=3)
    clf.fit(x_train, y_train)

    accuracy = clf.score(x_test,y_test)
    prediction = clf.predict(x)

    # Compute performance
    df0 = df = pd.read_csv("./csvs/features.csv", usecols=[1, 2, 3])
    df0['Does your work require sitting or moving more ?'] = df0['Does your work require sitting or moving more ?'].map({'Mostly moving (Involves movement more than 3days per week)': 3, 'Moderate (involves both sitting and moving)': 2, 'Mostly sitting (Involves movement less than 30 minutes per week)':1})


    df["id"] = df.index + 1
    df0['Adherence'] = df.apply(f, axis=1)
    df0= df.fillna(2)
    x = np.array(df0.drop(['Adherence'],1))

    prediction = clf.predict(x)
    df0['prediction'] = prediction
    def g(row):
        if row['prediction'] == 3:
            val = "HIGH"
        elif row['prediction'] == 2:
            val = "MEDIUM"
        else:
            val = "LOW"
        return val

    def h(row):
        if row['Does your work require sitting or moving more ?'] == 3:
            val = "HIGH"
        elif row['Does your work require sitting or moving more ?'] == 2:
            val = "MEDIUM"
        else:
            val = "LOW"
        return val
    df0['prediction'] = df0.apply(h, axis=1)
    df0['Estimation'] = df0.apply(h, axis=1)
    print(df0[:1])
    print ("Accuracy", accuracy)

    # Pass to CoachAI
    dfn = pd.read_csv("./csvs/features.csv")
    dfn['prediction'] = df0.apply(h, axis=1)
    dfn['Estimation'] = df0.apply(h, axis=1)

    dfn.to_csv("./csvs/result.csv", sep=',')


if __name__ == '__main__':
    main()
