#include <opencv2/opencv.hpp>
#include <stdio.h>

extern "C" void c_function(float *img, int* height_ptr, int* width_ptr) {
  int width = *width_ptr;
  int height = *height_ptr;
  
  cv::Mat image(height, width, CV_32FC3);

  printf("Image size: %d x %d\n", height, width);
  for (int h = 0; h < height; h++) {
    for (int w = 0; w < width; w++) {
	for (int c = 0; c < 3; c++) {
	  image.at<cv::Vec3f>(h, w)[c] = img[c + h * 3 + w * 3 * height] * 255;
	}
    }
  }

  // Convert image to integer
  image.convertTo(image, CV_8UC3);

  // Denoise
  cv::fastNlMeansDenoisingColored(image, image, 70, 10, 21, 7);
  


  cv::imwrite("output_image.png", image);
}

