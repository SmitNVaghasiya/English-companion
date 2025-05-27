import speech_recognition as sr
import logging
from fastapi import HTTPException
from io import BytesIO
from pydub import AudioSegment
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

logger = logging.getLogger(__name__)

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10),
    retry=retry_if_exception_type((sr.RequestError, OSError)),
    before_sleep=lambda retry_state: logger.info(
        f"Retrying STT attempt {retry_state.attempt_number} after {retry_state.idle_for}s due to {retry_state.outcome.exception()}"
    )
)
def voice_to_text(audio_bytes: bytes) -> str:
    """
    Converts uploaded audio bytes to text using Google Speech Recognition.
    Returns a fallback message if the STT service fails after retries.
    """
    recognizer = sr.Recognizer()
    try:
        logger.info("Processing audio bytes for speech-to-text conversion")
        if not audio_bytes:
            raise ValueError("Empty audio bytes provided")

        # Ensure the audio is in WAV format
        audio_segment = AudioSegment.from_file(BytesIO(audio_bytes), format="m4a")
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
        return "Sorry, I couldn't transcribe the audio due to a service error. Please try again or type your message."
    except Exception as e:
        logger.error(f"Unexpected STT error: {str(e)}")
        return "Sorry, I couldn't transcribe the audio. Please try again or type your message."