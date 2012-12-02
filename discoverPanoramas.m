clc
    
% Constants:
video_file = 'Mars.avi';
opt_flow_enabled = 0;
display_enabled = 0;

% Shot Detection Constants:
SAMPLING_RATE = 5;
EDGE_THRESHOLD = 0.1;
NUM_CHANGE_BLOCKS = 1;

% Discover Panoramas Constants:
DELTA = 100;
BETA = 1.2;





%Read Video
%video_frames = getVideo(video_file, 5);

% Extract List of shots:    
[shot_list num_shots FRAME_SIZE]  = extractShots(video_file, EDGE_THRESHOLD, NUM_CHANGE_BLOCKS, 1, SAMPLING_RATE);
fprintf('Number of shots found in video: %d\n', num_shots);

shot_num = 0;
for shot = shot_list
    
    shot_num = shot_num+1;

    % Obtain Quality Measures:        
    shot_frames = shot{1};
    fprintf('Number of frames in shot %d: %d', shot_num, size(shot_frames,4));
    [~, H_err, blurr, block, translations] = obtainQualityMeasures(shot_frames);

    % Extract Frames:
    [good_frames_idx] = extractGoodFrames(H_err', blurr', block', translations, FRAME_SIZE, DELTA, BETA)
    if(isempty(good_frames_idx))
        disp('No panoramas found in the input video file.');
        continue;
    end

    % Align Frames to Image:
    for num_pans=1:size(good_frames_idx,1)

        % Composite and Blend Images
        [stitched_img] = stitchImage(translations(good_frames_idx(num_pans,1):good_frames_idx(num_pans,2)-1,:), shot_frames(:,:,:,good_frames_idx(num_pans,1):good_frames_idx(num_pans,2)), ... 
                                    blurr(good_frames_idx(num_pans,1):good_frames_idx(num_pans,2)), block(good_frames_idx(num_pans,1):good_frames_idx(num_pans,2)));


        % Apply Optical Flow:
        if (opt_flow_enabled)


        end

        % Save Panorama Image in the directory as video - change later?:
        path = video_file(1:find(video_file=='\', 1, 'last'));
        file_name = video_file(find(video_file=='\', 1, 'last')+1:find(video_file=='.', 1, 'last')-1);
        if isempty(file_name)
            file_name=video_file(1:find(video_file=='.', 1, 'last')-1);
        end
        outputfile = sprintf('%spanorama_%s_%d_%d.jpg', path, file_name, shot_num, num_pans);
        imwrite(stitched_img, outputfile);

        % Display Image:
        if (display_enabled)
            figure(shot_num)
            imshow(stitched_img)
            title(['Panorama #' num2str(shot_num) ' in ' file_name]);
        end
    end  
    
end    
