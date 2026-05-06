from PIL import Image
import cv2
import numpy as np
import os

# set directory path in the following line
path = 'L:\\Lab_Members\\Jordan_Langford\\Master\'s Thesis\\Figures\\Raw Images'
os.chdir(path)

directory_list = os.listdir(path)

# Define a function to check if a file is an image
def image_file_finder(filename):
    valid_extensions = ['.png', '.jpg', '.jpeg', '.bmp', '.tif']
    return any(filename.lower().endswith(ext) for ext in valid_extensions)

# Function to process an image and save with a transparent background
def process_image(filename):
    img = cv2.imread(os.path.join(os.getcwd(), filename), cv2.IMREAD_UNCHANGED)
    img = cv2.cvtColor(img, cv2.COLOR_BGRA2RGBA)
    img = cv2.cvtColor(img, cv2.COLOR_BGRA2RGBA)
    
    # Create a mask for flood-filling
    h, w = img.shape[:2]
    mask = np.zeros((h+2, w+2), np.uint8)  # Mask needs to be 2 pixels larger
    
    # Use only BGR channels for flood fill
    floodfill_img = img[:, :, :3].copy()
    cv2.floodFill(floodfill_img, mask, (0, 0), (0, 0, 0), loDiff=(1,1,1), upDiff=(1,1,1), flags=cv2.FLOODFILL_MASK_ONLY)
    
    # Create the final transparency mask
    transparent_mask = mask[1:-1, 1:-1]  # Remove extra padding
    
    # Apply the transparency mask to the original image
    img[:, :, 3] = np.where(transparent_mask == 1, 0, img[:, :, 3])
    
    # Convert to Pillow image for cropping
    img_pil = Image.fromarray(cv2.cvtColor(img, cv2.COLOR_BGRA2RGBA))

    # Get the alpha channel (transparency mask)
    alpha = img_pil.split()[3]
    
    # Get bounding box of non-transparent areas
    bbox = alpha.getbbox()
    
    if bbox:
        # Crop the image using the bounding box
        img_cropped = img_pil.crop(bbox)
        
        # Save the cropped image
        output_filename = os.path.join(os.getcwd(), filename)
        img_cropped.save(output_filename)
        
# Filter directory_list to only include image files
directory_list = list(filter(image_file_finder, directory_list))

# Process all images in directory_list
list(map(process_image, directory_list))