import pyttsx3
import logging

logger = logging.getLogger(__name__)

def text_to_speech(text: str) -> None:
    """Converts text to speech using pyttsx3 and plays it."""
    try:
        engine = pyttsx3.init()
        voices = engine.getProperty('voices')
        if not voices:
            raise ValueError("No voices available for TTS")
        engine.setProperty('voice', voices[1].id)  # Voice of David
        engine.setProperty('rate', 192)  # Natural speech rate
        engine.setProperty('volume', 1.0)

        logger.info(f"Speaking: {text}")
        engine.say(text)
        engine.runAndWait()
        logger.info("Speech completed")
    except ValueError as ve:
        logger.error(f"TTS configuration error: {str(ve)}")
        raise
    except Exception as e:
        logger.error(f"Error during text-to-speech: {str(e)}")
        raise