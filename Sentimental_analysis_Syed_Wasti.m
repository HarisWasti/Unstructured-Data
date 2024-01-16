jsonFile = fileread("results.json");
jsonTotalData = jsondecode(jsonFile);
%%
% get 50 random samples
numPoints = 50;
totalRows = size(jsonTotalData, 1);
randomIndices = randperm(totalRows, numPoints);
randomIndices = sort(randomIndices);
jsonData = jsonTotalData(randomIndices, :);
%%
% sample the text column
textData = cell(length(jsonData), 1);

for i = 1:length(jsonData)
    if isfield(jsonData(i), 'CompleteReview')
        textData{i} = jsonData(i).CompleteReview;
    else
        textData{i} = 'No text available';
    end
end
%%
% text cleaning
lowercaseData=lower(textData);

npunctuationData = erasePunctuation(lowercaseData);

tokens = tokenizedDocument(npunctuationData);

stopWords = {'the', 'and', 'is', 'in', 'it', 'to', 'of', 'a', 'for', 'i', 'you', ...
    'he', 'she', 'it', 'they', 'them', 'theirs', 'us', 'me'};

filtered_Tokens = removeWords(tokens, stopWords);
%%
%Stemming tokens
stemmedTokens=normalizeWords(filtered_Tokens,'Style','stem');

%Lemmatising tokens
lemmatisedTokens=normalizeWords(filtered_Tokens,'Style','lemma');
%%
% bag of words
BoWFiltered=bagOfWords(filtered_Tokens);
BoWStem=bagOfWords(stemmedTokens);
BoWLemma=bagOfWords(lemmatisedTokens);

% world cloud
figure (1);
wordcloud(BoWFiltered);
figure (2);
wordcloud(BoWStem);
figure (3);
wordcloud(BoWLemma)
%%
% word embedding 
word2vecModel = trainWordEmbedding(filtered_Tokens);
wordEmbeddings = word2vecModel.Vocabulary;

%%
% sentiment metadata
metadata = struct('Review', textData, 'Sentiment', cell(size(textData)));

% Save the metadata to a JSON file
jsonMetadata = jsonencode(metadata);
fid = fopen('metadata.json', 'w');
fprintf(fid, '%s', jsonMetadata);
fclose(fid);
%%
% text metadata file
fid = fopen('metadata_process.txt', 'w');
edit('metadata_process.txt');

