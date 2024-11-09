import asyncio
import base64
import cv2
import json
import websockets

# Load pre-trained Haar Cascade for face detection
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')

async def stream_video(websocket):

    print("Client connected")

    # Open webcam
    cap = cv2.VideoCapture(0)
    
    if not cap.isOpened():
        print("Error: Could not open webcam")
        return

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            print("Error: Failed to capture frame")
            break

        # Flip the frame horizontally (left-right)
        frame = cv2.flip(frame, 1)

        # Convert the frame to grayscale for face detection
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        # Detect faces in the frame
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5, minSize=(30, 30))

        # Draw rectangles around the detected faces
        for (x, y, w, h) in faces:
            cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)

        # Resize frame to reduce size (optional)
        frame = cv2.resize(frame, (640, 480))

        # Encode frame as JPEG
        _, buffer = cv2.imencode('.jpg', frame)

        # Encode frame as JPEG with lower quality (0-100)
        _, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
        
        # Convert to base64 string
        jpg_as_text = base64.b64encode(buffer).decode('utf-8')

        # Convert face coordinates to list
        faces_list = [{"x": int(x), "y": int(y), "w": int(w), "h": int(h)} for (x, y, w, h) in faces]

        # Wrap the image and face data in a JSON object
        json_data = json.dumps({
            "image": jpg_as_text,
            "faces": faces_list
        })

        # Send the JSON over WebSocket
        await websocket.send(json_data)

        # ~30 fps
        await asyncio.sleep(0.033)

    cap.release()

async def main():
    print("Starting WebSocket server...")
    async with websockets.serve(stream_video, "localhost", 8765):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
