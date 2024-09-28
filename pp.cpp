#include <opencv2/opencv.hpp>
#include <stdio.h>

extern "C" void c_function(float *img, int* height_ptr, int* width_ptr) {
  int width = *width_ptr;
  int height = *height_ptr;
  
  cv::Mat image(height, width, CV_32FC3);

  for (int h = 0; h < height; h++) {
    for (int w = 0; w < width; w++) {
	for (int c = 0; c < 3; c++) {
	  image.at<cv::Vec3f>(h, w)[c] = img[(2-c) + h * 3 + w * 3 * height] * 255;
	}
    }
  }

  // Convert image to integer
  image.convertTo(image, CV_8UC3);


  // Downscale, averaging neighboring pixels
  cv::Mat downscale;
  cv::resize(image, downscale, cv::Size(), 0.8, 0.8, cv::INTER_AREA);

  // Compress as JPEG
  std::vector<uchar> buffer;
  cv::imencode(".jpg", downscale, buffer);
  // Write
  FILE *f = fopen("output.jpg", "wb");
  fwrite(buffer.data(), 1, buffer.size(), f);
  fclose(f);
  
}

