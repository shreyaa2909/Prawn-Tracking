
% Specify Video to be read in
video_in = 'source_sequence.avi';
% Initialize Video Reader
utilities.videoReader = VideoReader(video_in);

% Specify name for output video
video_out = 'Tracks.avi';
% Initialize Video writer
utilities.videoFWriter = vision.VideoFileWriter(video_out,'FrameRate',30);
%utilities.videoFWriter.VideoCompressor='DV Video Encoder';

% Compress the output video as it will be very big if you don't. The
% compression options depend on your operating system, so maybe you will
% need to use the following instead of the current settings:
% utilities.videoFWriter.VideoCompressor='DV Video Encoder';
% for further details see: 
% https://se.mathworks.com/help/vision/ref/vision.videofilewriter-system-object.html
%utilities.videoFWriter.VideoCompressor='MJPEG Compressor';

% Initialize video player if you want to watch video with tracking results
% while running the code (will slow down code significantly of course)
utilities.videoPlayer=vision.VideoPlayer('Position',[100,100,500,400]);


% Get number of frames
N_frames=utilities.videoReader.NumberOfFrames;
   Area2=zeros(8,581);
Centroid2=0;
% Loop through frames
for i=1:N_frames
    % Read in next frame
    frame = read(utilities.videoReader,i);
    bin=im2bw(frame);
    bin=~bin;
    
    SE = strel('line',7,30)
    erodedBW = imerode(bin,SE);
    imshow(erodedBW);
    
    labels= bwlabel(erodedBW,4);
    stats = regionprops(labels, 'Area', 'Centroid', 'Image');
  
        sh= cat(1,stats.Area,1);
          [g c ]=size(sh);
         Area2(1:g,i)= sh;
         
    Centroid3= Centroid2;
    Centroid2 = cat(1,stats.Centroid);
    k = 1;
  
 indices = zeros();
 [ r c]=size(Area2);
 dist1=inf;
 temp_x=zeros(3,1);
 temp_y=zeros(3,1);

    if i==1
        for j=1:r
            if Area2(j,1)>10
            temp_x(k)=Centroid2(j,1);
            temp_y(k)=Centroid2(j,2);
            k=k+1;
            end
        end
    else
        k=1;
        u=0;
    for j=1:r
         if   Area2(j,i)>10
             track_x(k)=Centroid2(j,1);
             track_y(k)=Centroid2(j,2);
             k=k+1;
         else
             u=u+1;
        end
    end
           for s=1:length(track_x)
            for h=1:length(temp_x)
                
                %dist= ((Centroid3(h,1) -track_x(s))^2)+((Centroid3(h,2) -track_y(s))^2);
                dist= ((temp_x(h,1) -track_x(1,s))^2)+((temp_y(h,1) -track_y(1,s))^2);
                if dist<dist1
                    temp_x(s)= (track_x(1,s));
                    temp_y(s)=(track_y(1,s));
                    dist1=dist;
                elseif dist1<dist
                        g=1;
                    temp_x(s)= (track_x(1,h-g));
                    temp_y(s)=(track_y(1,h-g));
                    dist1=dist;
                    g=g+1;
                end
             dist1=inf;
            end
            end
            
        
   
    end
   
     
    % Process frame
    % (for example feature extraction, segmentation, object detection...)
    % ...
    %
    
    
    
    % here we have three points wandering through the video, such that you
    % can see how you can do the annotations in the video
    trackedLocation=[temp_x(1),temp_y(1); temp_x(2),temp_y(2); temp_x(3),temp_y(3)];
   % trackedLocation=[1+i,1; 2,2+i; 3+i,3+i];

    % mark the position in every tenth frame for example
    if mod(i,10)
    if ~isempty(trackedLocation)
        shape = 'circle';
        region = trackedLocation;
        region(:, 3) = 5;
        label=1:1:length(trackedLocation(:,1));
        combinedImage = insertObjectAnnotation(frame,shape,...
            region, label, 'Color', 'red');
    end
    end
 
    % Take a step in playing the video with tracks if you want to watch it
    % while running the code
    
    step(utilities.videoPlayer, combinedImage);
    step(utilities.videoFWriter,combinedImage);
    
end

% Release and close all video related objects
release(utilities.videoPlayer);
release(utilities.videoFWriter);


              % utilities.videoFWriter.VideoCompressor='DV Video Encoder'
