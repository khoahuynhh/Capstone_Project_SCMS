import Webcam from "react-webcam";
import { useRef, useState } from "react";

export default function Camera() {
    const webcamRef = useRef(null);
    const [img, setImg] = useState(null);

    const capture = () => {
        const imageSrc = webcamRef.current.getScreenshot();
        setImg(imageSrc);
    };

    return (
        <div className="flex flex-col items-center gap-4 p-4">
        {!img ? (
            <>
            <Webcam
                ref={webcamRef}
                screenshotFormat="image/jpeg"
                className="w-full max-w-md rounded-lg border"
            />
            {/* <button
                onClick={capture}
                className="px-4 py-2 bg-green-500 text-white rounded-lg"
            >
                Chụp ảnh
            </button> */}
            </>
        ) : (
            <>
            <img src={img} alt="captured" className="rounded-lg border" />
            <button
                onClick={() => setImg(null)}
                className="px-4 py-2 bg-blue-500 text-white rounded-lg"
            >
                Mở lại Camera
            </button>
            </>
        )}
        </div>
    );
}
