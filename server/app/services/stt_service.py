import speech_recognition as sr
import logging
from fastapi import HTTPException
from io import BytesIO
from pydub import AudioSegment

logger = logging.getLogger(__name__)

def voice_to_text(audio_bytes: bytes) -> str:
    """
    Converts uploaded audio bytes to text using Google Speech Recognition.
    """
    recognizer = sr.Recognizer()
    try:
        logger.info("Processing audio bytes for speech-to-text conversion")
        # Ensure the audio is in WAV format
        audio_segment = AudioSegment.from_file(BytesIO(audio_bytes), format="wav")
        audio_segment = audio_segment.set_channels(1)  # Mono
        audio_segment = audio_segment.set_frame_rate(16000)  # 16kHz
        audio_segment = audio_segment.set_sample_width(2)  # 16-bit PCM

        # Export to WAV format for speech recognition
        with BytesIO() as wav_file:
            audio_segment.export(wav_file, format="wav")
            wav_file.seek(0)
            audio_data = wav_file.read()

        # Process with speech recognition
        logger.info("Starting speech recognition")
        with sr.AudioFile(BytesIO(audio_data)) as source:
            audio = recognizer.record(source)
            text = recognizer.recognize_google(audio)
            logger.info(f"Recognized text: {text}")
            return text
    except sr.UnknownValueError:
        logger.warning("Could not understand audio")
        raise HTTPException(status_code=400, detail="Could not understand audio")
    except sr.RequestError as e:
        logger.error(f"Google Speech Recognition service error: {str(e)}")
        raise HTTPException(status_code=503, detail="Speech recognition service unavailable")
    except Exception as e:
        logger.error(f"Unexpected STT error: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to process audio input")