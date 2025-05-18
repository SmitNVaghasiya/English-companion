import speech_recognition as sr
import logging
from fastapi import HTTPException

logger = logging.getLogger(__name__)

def voice_to_text(timeout: int = 5, phrase_time_limit: int = 10, max_retries: int = 3) -> str:
    """
    Listens for speech, recognizes it using Google Speech Recognition, and returns the text.
    Retries up to max_retries times if speech is not detected or understood.
    """
    recognizer = sr.Recognizer()
    retry_count = 0

    while retry_count < max_retries:
        try:
            with sr.Microphone() as source:
                logger.info("Listening for voice input...")
                recognizer.adjust_for_ambient_noise(source, duration=2)
                audio = recognizer.listen(source, timeout=timeout, phrase_time_limit=phrase_time_limit)
                logger.info("Processing speech...")
                text = recognizer.recognize_google(audio)
                logger.info(f"Recognized text: {text}")
                return text
        except sr.UnknownValueError:
            retry_count += 1
            logger.warning(f"Could not understand audio (attempt {retry_count}/{max_retries}), retrying...")
            continue
        except sr.RequestError as e:
            logger.error(f"Google Speech Recognition service error: {str(e)}")
            raise HTTPException(status_code=503, detail="Speech recognition service unavailable")
        except sr.WaitTimeoutError:
            retry_count += 1
            logger.info(f"No speech detected (attempt {retry_count}/{max_retries}), retrying...")
            continue
        except Exception as e:
            logger.error(f"Unexpected STT error: {str(e)}")
            raise HTTPException(status_code=500, detail="Failed to process audio input")
    
    logger.error(f"Max retries ({max_retries}) reached, no valid speech detected")
    raise HTTPException(status_code=408, detail="Timeout: No valid speech detected after retries")