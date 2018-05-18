%%
%
% officelens:
%  edge detection to localize the board?s boundaries, 
%  white balancing to deliver a uniformly white background, 
%  and strong color saturation for pen strokes


%%
pipeline for mobile scanner:

1. Image Registration
   Identify the markings on the image to locate the target image
   May use: Hough transform for line detection
            Feature Point detection for corner detection and marking detection
   
   (For individual modules (such as numerical algorithms for solving an optimization problem,
    extracting sophisticated features such as SIFT, error correction coding/decoding, etc.), 
    you may use available image processing/vision libraries))
  
2. Perspective Transform
   (Estimate geometric transform from matching point pairs - MATLAB)

   Transform the target image identified in step 1, which has geometric distrotions,
   warping (and non-uniform lighting and contrast), to a rectangular image
   (tackle geometric distortions)
   
3. Image Enhancement
   Tackle the non-uniform lighting and contrast:
   
   Filtering with morphological operators 
   (Dilate, erode, reconstruct, and perform other morphological operations)
   % see https://www.mathworks.com/help/images/morphological-filtering.html
   
   Histogram equalization
   Noise removal using a Wiener filter
   Linear contrast adjustment
   Median filtering
   Unsharp mask filtering
   Contrast-limited adaptive histogram equalization (CLAHE)
   Decorrelation stretch
   
  