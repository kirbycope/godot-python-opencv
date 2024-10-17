import asyncio
import base64
import cv2
import numpy as np
import websockets


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

        # Resize frame to reduce size (optional)
        #frame = cv2.resize(frame, (640, 480))

        # Encode frame as JPEG
        _, buffer = cv2.imencode('.jpg', frame)

        # Encode frame as JPEG with lower quality (0-100)
        _, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
        
        # Convert to base64 string
        jpg_as_text = base64.b64encode(buffer).decode('utf-8')

        # Send frame over WebSocket
        await websocket.send(jpg_as_text)

        # ~30 fps
        await asyncio.sleep(0.033)

    cap.release()


async def main():
    print("Starting WebSocket server...")
    async with websockets.serve(stream_video, "localhost", 8765):
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())
