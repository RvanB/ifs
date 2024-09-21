import numpy as np
import cv2
import os

files = os.listdir("stack")

# Stack (average) image in "stack" folder
stack = np.zeros((1440, 3440, 3), dtype=np.float32)
for file in files:
    try:
        img = cv2.imread("stack/" + file).astype(np.float32)
    except Exception as e:
        continue
    stack += img / len(files)

stack = stack.astype(np.uint8)
cv2.imwrite("stack.png", stack)
