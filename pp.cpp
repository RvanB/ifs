#include <opencv2/opencv.hpp>
#include <stdio.h>

extern "C" void post_process(float *img, int* height_ptr, int* width_ptr, const char* filename) {
  int width = *width_ptr;
  int height = *height_ptr;

  printf("Saving image of size %dx%d to %s\n", width, height, filename);
  
  cv::Mat image(height, width, CV_32FC4);

  for (int h = 0; h < height; h++) {
    for (int w = 0; w < width; w++) {
      // Access each channel correctly
      float* pixel = image.ptr<float>(h, w); // Get pointer to the pixel (h, w)
      pixel[0] = img[2 + h * width * 4 + w * 4] * 255;     // Blue
      pixel[1] = img[1 + h * width * 4 + w * 4] * 255;     // Green
      pixel[2] = img[0 + h * width * 4 + w * 4] * 255;     // Red
      pixel[3] = img[3 + h * width * 4 + w * 4] * 255;     // Alpha
    }
  }

  // Convert image to integer
  image.convertTo(image, CV_8UC4);  

  // Write the image
  cv::imwrite(filename, image);

  // Open image viewer
  cv::imshow("image", image);
  cv::waitKey(0);
  

  

  // // Downscale, averaging neighboring pixels
  // cv::Mat downscale;
  // cv::resize(image, downscale, cv::Size(), 0.5, 0.5, cv::INTER_AREA);

  // // Compress as JPEG
  // std::vector<uchar> buffer;
  // cv::imencode(".jpg", downscale, buffer);
  
  // // Write
  // FILE *f = fopen(filename, "wb");
  // fwrite(buffer.data(), 1, buffer.size(), f);
  // fclose(f);
}

