# Problem statement: Taking an input of a text review, predict the sentiment from it

# Import functions
import numpy as np
import pandas as pd
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import nltk
from nltk.corpus import stopwords
import string
from keras.preprocessing.text import text_to_word_sequence 
from tensorflow.python.keras.models import Sequential
from tensorflow.python.keras.layers import Dense, Embedding, GlobalAveragePooling1D
from keras.models import load_model

#importing dataset
dataset = pd.read_csv('reviews_dump_test.csv')

#cleaning Dataset
df = dataset
#checking for substring within captions
df.loc[df['caption'].str.contains("Translated by Google", case=True, na=False)]
#adding a flag for originally non-english captions
df.loc[df['caption'].str.contains('Translated by Google', case=True, na=False),'NotEnglish'] = 1
#remove 'translated by...' string in the caption
df["caption"] = df["caption"].str.replace("(Translated by Google) ", "",regex=False)
# converting nan to string for 'caption' column:
# MAY WANT TO DROP ROWS WITH NO CAPTION
df['caption'] = df['caption'].fillna('')
#cleaning number formates for 'n_review_user'
df["n_review_user"] = df["n_review_user"].str.strip()
df["n_review_user"] = df["n_review_user"].str.replace(",","")
df["n_review_user"] = df["n_review_user"].str.replace("· ", "")
df["n_review_user"] = df["n_review_user"].str.replace(" reviews", "")
df["n_review_user"] = df["n_review_user"].str.replace(" review", "")
df["n_review_user"] = df['n_review_user'].astype(str).astype(int)
#converting 'notEnglish' to Boolean
df['NotEnglish'] = df['NotEnglish'].fillna(0)
df["NotEnglish"] = df['NotEnglish'].astype(bool)
#removes numbers from the string
df["caption"] = df['caption'].str.replace('\d+', '')

# applying sentiment data as predicting variable
df['sentiments'] = df.rating.apply(lambda x: 0 if x in [1, 2, 3] else 1)

#text processing to remove spaces and stopwords. 
#function to eliminate the special characters, stopwords and numbers in the “Review” column and put them into a bag of words. We will eliminate the numbers first, and then we will remove the stopwords like “the”, “a” which won’t affect the sentiment
def text_processing(text):
    nopunc = []
    for char in text:
        if char not in string.punctuation:
            if char!=str("0") and char!=str("1"):
                nopunc.append(char)
    nopunc = ''.join(nopunc)
    
    return [word for word in nopunc.split() if word.lower() not in stopwords.words('english')]
    
#processing text into a list of words
df["BagOfWords"] = df["caption"].apply(text_processing)
x = df["BagOfWords"]
df["sentiments"] = df["sentiments"].astype(str).astype(int)
y = df["sentiments"]

# Train-Test split
from sklearn.model_selection import train_test_split 
X_train, X_test, y_train, y_test = train_test_split(x, y, test_size=0.25, random_state=1)

#creating output dataframe before text tokenization
df_output = pd.DataFrame()
df_output['BagOfWords'] = X_test
df_output['GivenSentiment'] = y_test

# Tokenizing Feature data
tokenizer = Tokenizer(num_words=5000)
tokenizer.fit_on_texts(X_train)
X_train = tokenizer.texts_to_sequences(X_train)
X_test = tokenizer.texts_to_sequences(X_test)
word_index = tokenizer.word_index

# Making the train and test lists to be of size 120 by truncating or padding accordingly

#initializing text processing variables for keras
vocab_size = 40000
embedding_dim = 16
max_length = 120
trunc_type = 'post'
oov_tok = '<OOV>'
padding_type = 'post'

#padding/trucating
X_train = pad_sequences(X_train, maxlen=max_length, truncating=trunc_type)
X_test = pad_sequences(X_test, maxlen=max_length, truncating=trunc_type)

#initializing Model
model = Sequential([Embedding(vocab_size, embedding_dim,input_length=max_length), 
                   GlobalAveragePooling1D(),
                   Dense(17,activation = "relu"),
                   Dense(12,activation = "relu"),
                   Dense(1,activation = "sigmoid")])
model.compile(
    loss = "binary_crossentropy",
    optimizer =  "adam",
    metrics = ["accuracy"])
model.summary()

# Fit model to training data
model.fit(X_train, y_train, validation_data=(X_test, y_test), epochs=20, verbose = 1)

#printing model accuracy
loss, accuracy = model.evaluate(X_test, y_test)
print("Accuracy is : ",accuracy*100)

# Saving model
model.save('my_model_prep3.h5')  # creates a HDF5 file 'my_model.h5'

# load the model from disk
model1 = load_model('my_model_prep3.h5')

#predict based on model
y_pred = model1.predict(X_test)

# write output dataframe as a csv
df_output['PredSentiment'] = y_pred
df_output.to_csv('outputfile.csv')