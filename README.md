# MultiResolutionIterators

There are many different ways to look at text corpora.
The true structure of a corpus might be:
 - **Corpus**
 - made up of: **Documents**
 - made up of: **Paragraphs**
 - made up of: **Sentences**
 - made up of: **Words**
 - made up of: **Characters**

Very few people want to consider it at that level.
 - Someone working in **Information Retrieval** might want to consider the corpus as **Corpus made up of Documents made up of Words**.
 - Someone working on **Language Modeling** might want to consider **Corpus made up of Words**
 - Someone working on **Parsing** might want to consider **Corpus made up Sentences made up of Words**.
 - Someone training a **Char-RNN** might want to consider **Corpus made up of Characters**.

 This package lets you better work with iterators of iterators to allow them to be flattened and viewed at different levels.
