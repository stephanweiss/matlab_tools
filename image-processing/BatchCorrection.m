function BatchCorrection(path_bkg, bkg_num, root_bkg, ...
    path_image, root_image, ...
    genum, path_output, varargin)
% BatchCorrection - Corrects a batch of images. Currently implements only
% the background subtraction.
%
%   USAGE:
%
%   BatchCorrection(path_bkg, bkg_num, root_bkg, ...
%                       path_image, root_image, ...
%                       genum, path_output)
%   BatchCorrection(path_bkg, bkg_num, root_bkg, ...
%                       path_image, root_image, ...
%                       genum, path_output, varargin)
%
%   INPUT:
%
%   path_bkg            path where background file(s) are located.
%
%   bkg_num             if there are multiple background images, the low 
%                       and high values of the background images can be 
%                       provided and the function averages over all background images.
%
%   root_bkg            root of the background images
%
%	path_image          path where the the data image(s) are located.
%
%   root_image          root of the image(s) data
%	
%   genum               GE detector number (1 - 4)
%
%   path_output         output path
%
%   These arguments can be followed by a list of
%   parameter/value pairs which control certain plotting
%   features.  Options are:
%
%   CorrectAllImages    corrects all images in the path_image {false}. note
%                       that this option overrides any lo or hi image number inputs
%
%   lo                  lowest number in the image series
%
%   hi                  highest number in the image series
%
%   OutAllFrames        output all corrected frames in a fastsweep file
%
%   OUTPUT:             
%                   
%   (possibly) many files
%
%   NOTE:
%       1. Need to implement bad pixel correction
%       2. Need to implement flipping
%       3. This function is same as "batchcorrNP.py"
%

%%% DEFAULT PARAMETERS
npad        = '00000';
buffer_size = 8192;
frame_size  = 2048*2048*2;

% DEFAULT OPTIONS
optcell = {...
    'CorrectAllImages', true, ...
    'hi', -1, ...
    'lo', -1, ...
    'OutAllFrames', false, ...
    'DisplayFrames', false, ...
    };

% UPDATE OPTION
opts    = OptArgs(optcell, varargin);

%%% SETUP APPROPRIATE EXTENSION
ext_bkg     = ['ge', num2str(genum)];
ext_image   = ext_bkg;
%%% BAD PIXEL CORRECTION    %%% NOT YET IMPLEMENTED
%%% GE2 == 'DetectorData\1339.6\Full\1339.6Full_BadPixel_d.txt.img'

tic
%%% CONSTRUCT BACKGROUND IMAGE
im_bkg  = zeros(2048,2048);
ct  = 0;
for i = 1:1:length(bkg_num)
    fname	= [root_bkg, npad(1:length(npad)-length(num2str(bkg_num(i)))) num2str(bkg_num(i)), '.', ext_bkg];
    pfname  = fullfile(path_bkg, fname);
    
    flist       = dir(pfname);
    num_frame   = CalcNumFrames(flist.bytes, buffer_size, frame_size);
    
    for j = 1:1:num_frame
        im_bkg  = im_bkg + NreadGE(pfname, j);
        ct  = ct + 1;
    end
end
im_bkg  = im_bkg./ct;
if opts.DisplayFrames
    PlotImage(im_bkg, max(im_bkg(:)), min(im_bkg(:)))
end

if opts.CorrectAllImages
    cmd = ['flist = dir(''', path_image, filesep, '*.', ext_image, ''');'];
    eval(cmd)
    if isempty(flist)
        error('specified files do not exist');
    end
    
    for i = 1:1:length(flist)
        fname   = flist(i).name;
        pfname  = fullfile(path_image, fname);
        
        num_frame   = CalcNumFrames(flist(i).bytes, buffer_size, frame_size);
        disp(fname)
        
        sum_data    = zeros(2048,2048);
        for j = 1:1:num_frame
            disp('background subtraction in progress ...')
            frame_data  = NreadGE(pfname, j);
            frame_data  = frame_data - im_bkg;
            sum_data    = sum_data + frame_data;
            
            if opts.DisplayFrames
                PlotImage(frame_data, max(frame_data(:)), min(frame_data(:)))
            end
            
            if opts.OutAllFrames
                WriteCorrectedFile(frame_data, path_output, flist(i).name, ['frame.', num2str(j), '.cor']);
            end
        end
        
        %%% WRITE OUT SUM FILE
        WriteCorrectedFile(sum_data, path_output, flist(i).name, 'sum');
        
        %%% WRITE OUT AVE FILE
        ave_data    = sum_data./num_frame;
        WriteCorrectedFile(ave_data, path_output, flist(i).name, 'ave');
    end
else
    image_num   = opts.lo:1:opts.hi;
    for i = 1:1:length(image_num)
        fname	= [root_image, npad(1:length(npad)-length(num2str(image_num(i)))) num2str(image_num(i)), '.', ext_image];
        pfname  = fullfile(path_bkg, fname);
        
        flist       = dir(pfname);
        num_frame   = CalcNumFrames(flist.bytes, buffer_size, frame_size);
        disp(fname)
        
        sum_data    = zeros(2048,2048);
        for j = 1:1:num_frame
            disp('background subtraction in progress ...')
            frame_data  = NreadGE(pfname, j);
            frame_data  = frame_data - im_bkg;
            sum_data    = sum_data + frame_data;
            
            if opts.DisplayFrames
                PlotImage(frame_data, max(frame_data(:)), min(frame_data(:)))
            end
            
            if opts.OutAllFrames
                WriteCorrectedFile(frame_data, path_output, flist.name, ['frame.', num2str(j), '.cor']);
            end
        end
        
        %%% WRITE OUT SUM FILE
        WriteCorrectedFile(sum_data, path_output, flist.name, 'sum');
        
        %%% WRITE OUT AVE FILE
        ave_data    = sum_data./num_frame;
        WriteCorrectedFile(ave_data, path_output, flist.name, 'ave');
    end
end
toc

function PlotImage(image_data, max_range, min_range)
figure,
clf
%%% CHANGE RANGE AS DESIRED
imagesc(image_data, [min_range max_range])
colorbar vert
axis square tight

function num_frame = CalcNumFrames(bytes, buffer_size, frame_size)
num_frame   = (bytes - buffer_size)/frame_size;
return

function WriteCorrectedFile(data, pname_out, fname, extension)
fname_out   = fname(1:end-3);
fname_out   = [fname_out, extension];
pfname_out  = fullfile(pname_out, fname_out);

fid     = fopen(pfname_out, 'w');
fwrite(fid, data, 'uint16');
fclose(fid);