import cv2

# Attempt to open the webcam
cap = cv2.VideoCapture(0)  # Change to 1 if necessary

if not cap.isOpened():
    print("Error: Could not open webcam")
else:
    print("Webcam opened successfully")

while cap.isOpened():
    ret, frame = cap.read()
    
    if not ret:
        print("Failed to grab frame")
        break
    
    cv2.imshow('frame', frame)

    # Check if 'q' is pressed to exit
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the webcam and close windows
cap.release()
cv2.destroyAllWindows()
