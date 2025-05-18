from pydantic import BaseModel, validator, Field
from typing import List, Literal, Optional
from datetime import datetime

class Message(BaseModel):
    role: Literal['system', 'user', 'assistant']
    content: str
    timestamp: Optional[str] = None
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

class ChatInput(BaseModel):
    messages: List[Message] = Field(..., min_items=1, description="List of chat messages")
    
    @validator('messages')
    def validate_messages(cls, v):
        if not any(msg.role == 'user' for msg in v):
            raise ValueError("At least one user message is required")
        return v
