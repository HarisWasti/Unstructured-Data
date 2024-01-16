images_new = dir('C:\Users\haris\OneDrive\Desktop\Images\');
clean_images = ('C:\Users\haris\OneDrive\Desktop\clean_images\');
rows_to_delete = [1, 2];
images_new(rows_to_delete, :) = [];
images_count = length(images_new);

if ~isfolder(clean_images)
    mkdir(clean_images);
end

% sizes of all images before resizing
disp('Dimensions of images before resizing:');
for i = 1:images_count
    currentImagePath = fullfile('C:\Users\haris\OneDrive\Desktop\Images\', images_new(i).name);
    currentImage = imread(currentImagePath);
    [height, width, ~] = size(currentImage);
    disp(['Image ' num2str(i) ' - Height: ' num2str(height) ', Width: ' num2str(width)]);
end

% Loops and copies and renames all jpgs to new dir
for i = 1:images_count
    oldName = fullfile('C:\Users\haris\OneDrive\Desktop\Images\', images_new(i).name);
    newName = fullfile(clean_images, [num2str(i) '.jpg']);
    copyfile(oldName, newName);
end

% makes clean_images the new directory
cd(clean_images);

% set the new size
max_width = 500;
max_height = 500;

% an array to store the mean values
image_means = zeros(images_count, 1);

% Loop through all images
for i = 1:images_count
    % Read the image
    imagedata = imread(fullfile(clean_images, [num2str(i) '.jpg']));
    
    % Resize the image if it exceeds the maximum pixels
    [height, width, ~] = size(imagedata);
    if height > max_height || width > max_width
        imagedata = imresize(imagedata, [max_height, max_width]);
    end

    % Display the dimensions after resizing
    disp(['Image ' num2str(i) ' - Height after resizing: ' num2str(size(imagedata, 1)) ', Width after resizing: ' num2str(size(imagedata, 2))]);
    
    % Calculate the mean value and store it in the array
    image_means(i) = mean(imagedata, 'all');
end

% Display the mean values
disp('Mean values for each image:');
disp(image_means);

%%

% cell arrays to store keywords and descriptions for each image
keywords = cell(images_count, 1);
descriptions = cell(images_count, 1);

% Loop through all images for manual annotation
for i = 1:images_count
    % Read the image
    imagedata = imread(fullfile(clean_images, [num2str(i) '.jpg']));
    
    % Display the image for annotation
    figure;
    imshow(imagedata);
    title(['Image ' num2str(i) ' - Annotation']);
    
    % Prompt the user for keywords and descriptions
    prompt_keywords = 'Enter keywords: ';
    keywords_str = input(prompt_keywords, 's');
    keywords{i} = strsplit(keywords_str, ',');
    
    prompt_description = 'Enter description: ';
    descriptions{i} = input(prompt_description, 's');
    
    % Close the image display window
    close;
end
%%
% Create a struct array to store metadata
metadata = struct('ImageID', {}, 'Keywords', {}, 'Description', {});

% Populate the struct array with metadata
for i = 1:images_count
    metadata(i).ImageID = num2str(i);
    metadata(i).Keywords = keywords{i};
    metadata(i).Description = descriptions{i};
end

% Convert struct array to JSON format
json_str = jsonencode(metadata);

% Specify the file path for the JSON file
json_file_path = 'Metadata_images.json';

% Check if the file already exists
if exist(json_file_path, 'file')
    disp('Metadata file already exists. Overwriting...');
end

% Write JSON data to the file
fid = fopen(json_file_path, 'w');
fprintf(fid, '%s', json_str);
fclose(fid);

disp(['Metadata successfully saved to ' json_file_path]);

%%

% an empty cell array to store feature information
feature_data = cell(images_count, 1);

for i = 1:images_count
    % Read the image
    imagedata = imread(fullfile(clean_images, [num2str(i) '.jpg']));
    
    % Extract color features
    red_channel = imagedata(:,:,1);
    green_channel = imagedata(:,:,2);
    blue_channel = imagedata(:,:,3);
    
    % Calculate mean and standard deviation for each channel
    red_mean = mean(red_channel(:));
    red_std = std(double(red_channel(:)));
    
    green_mean = mean(green_channel(:));
    green_std = std(double(green_channel(:)));
    
    blue_mean = mean(blue_channel(:));
    blue_std = std(double(blue_channel(:)));
    
    % Store the features in a cell array
    features = struct('file', [num2str(i) '.jpg'], ...
                      'red', struct('mean', red_mean, 'std', red_std), ...
                      'green', struct('mean', green_mean, 'std', green_std), ...
                      'blue', struct('mean', blue_mean, 'std', blue_std));
                  
    feature_data{i} = features;
end

% Convert the cell array to a JSON-formatted string
json_str = jsonencode(feature_data);

% Write the JSON string to a file
json_file_path = 'feature_extraction_colour.json';
fid = fopen(json_file_path, 'w');
fprintf(fid, '%s', json_str);
fclose(fid);


%%

% the directory where the grayscale images will be saved
gray_images_directory = 'clean_gray_images';

% Create the 'clean_gray_images' directory if it doesn't exist
if ~exist(gray_images_directory, 'dir')
    mkdir(gray_images_directory);
end

% Loop through each image
for i = 1:images_count
    % Read the original image
    imagedata = imread(fullfile(clean_images, [num2str(i) '.jpg']));

    % Convert the image to grayscale
    grayscale_image = rgb2gray(imagedata);

    % Save the grayscale image in the 'clean_gray_images' directory
    imwrite(grayscale_image, fullfile(gray_images_directory, ['grayscale_' num2str(i) '.jpg']));
end


%%
