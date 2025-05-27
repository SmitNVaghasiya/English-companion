# from fastapi.middleware.cors import CORSMiddleware

# def add_cors_middleware(app):
#     """Add CORS middleware to the FastAPI app."""
#     app.add_middleware(
#         CORSMiddleware,
#         allow_origins=["*"],  # Replace with specific origins in production
#         allow_credentials=True,
#         allow_methods=["*"],
#         allow_headers=["*"],
#         expose_headers=["*"],
#     )


from fastapi.middleware.cors import CORSMiddleware

def add_cors_middleware(app):
    """Add CORS middleware to the FastAPI app with restricted origins."""
    app.add_middleware(
        CORSMiddleware,
        # allow_origins=["http://localhost:8080", "https://your-flutter-app-domain.com"],
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["GET", "POST"],
        # allow_headers=["Content-Type", "Authorization"]
        allow_headers=["*"],
        expose_headers=["*"],
    )