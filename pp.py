import argparse
import cv2
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("image", type=str)
parser.add_argument("-f", "--first-step", type=int, default=10)
parser.add_argument("-l", "--last-step", type=int, default=10)
parser.add_argument("-s", "--step", type=int, default=10)
parser.add_argument("-b", "--blur", type=int, default=50)
args = parser.parse_args()

# Make blur odd
if args.blur % 2 == 0:
    args.blur += 1

# Split image name and extension
image_name, image_extension = args.image.split(".")

# Read image
image = cv2.imread(args.image)

# Blur the image
image = cv2.GaussianBlur(image, (args.blur, args.blur), 0)

# Create a blank image with the same shape
contour_image = np.zeros_like(image)
bloom_image = np.zeros_like(image)

for i in range(args.first_step, 255 - args.last_step, args.step):
    # Convert image to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Apply threshold
    _, thresh = cv2.threshold(gray, i, 255, cv2.THRESH_BINARY)

    # Find contour lines
    contours, _ = cv2.findContours(thresh, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

    # Draw contour lines
    cv2.drawContours(contour_image, contours, -1, (255, 255, 255), 1)
    cv2.drawContours(bloom_image, contours, -1, (20, 180, 70), 5)

# Add some bloom-like effect
bloom_image = cv2.GaussianBlur(bloom_image, (11, 11), 0)

# Overlay bloom_image white pixels on bloom_image
contour_image = cv2.GaussianBlur(contour_image, (3, 3), 0)
contour_image = cv2.addWeighted(contour_image, 1.5, bloom_image, 1, 0)

# Clip to 0-255
contour_image = np.clip(contour_image, 0, 255)

cv2.imwrite(f"{image_name}-pp.jpg", contour_image)
