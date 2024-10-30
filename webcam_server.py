import asyncio
import base64
import cv2
import json
import numpy as np
import websockets
import mediapipe as mp

# Initialize MediaPipe pose and drawing utils
mp_pose = mp.solutions.pose
mp_drawing = mp.solutions.drawing_utils
pose = mp_pose.Pose()

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

        # Resize frame to reduce size (optional)
        frame = cv2.resize(frame, (640, 480))

        # Perform pose detection
        image_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = pose.process(image_rgb)

        # Draw pose landmarks on the frame if detected
        if results.pose_landmarks:
            mp_drawing.draw_landmarks(
                frame,
                results.pose_landmarks,
                mp_pose.POSE_CONNECTIONS,
                mp_drawing.DrawingSpec(color=(0, 255, 0), thickness=2, circle_radius=2),
                mp_drawing.DrawingSpec(color=(0, 0, 255), thickness=2, circle_radius=2)
            )

        # Encode frame as JPEG with lower quality (0-100)
        _, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
        
        # Convert to base64 string
        jpg_as_text = base64.b64encode(buffer).decode('utf-8')

        # Prepare landmarks for JSON if detected
        landmarks = []
        if results.pose_landmarks:
            for landmark in results.pose_landmarks.landmark:
                landmarks.append({
                    'x': landmark.x,
                    'y': landmark.y,
                    'z': landmark.z
                })

        # Wrap the image and pose data in a JSON object
        json_data = json.dumps({
            "image": jpg_as_text,
            "landmarks": landmarks
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
