# agent/tools/extraction_tools.py
import logging
import os
from typing import Dict, Any, Optional
import google.generativeai as genai
from google.generativeai import types

logger = logging.getLogger(__name__)

# Configure Gemini API
genai.configure(api_key=os.getenv("GOOGLE_API_KEY"))

def extract_from_file(file_path: str, query: str = "Describe this file") -> Dict[str, Any]:
    """
    Extract information from a file (image or PDF) using Gemini 1.5 Flash.
    
    Args:
        file_path: Local path to the file
        query: Specific question about the file content
        
    Returns:
        Dictionary with extraction results
    """
    try:
        if not file_path:
            return {"status": "error", "error": "No file path provided"}
            
        if not os.path.exists(file_path):
            return {"status": "error", "error": f"File not found: {file_path}"}
            
        # Determine mime type
        mime_type = "application/pdf" if file_path.lower().endswith(".pdf") else "image/jpeg"
        if file_path.lower().endswith(".png"):
            mime_type = "image/png"
            
        # Upload file to Gemini
        sample_file = genai.upload_file(path=file_path, display_name="User Upload")
        logger.info(f"Uploaded file '{sample_file.display_name}' as: {sample_file.uri}")
        
        # Initialize model
        model = genai.GenerativeModel(model_name="gemini-1.5-flash")
        
        # Generate content
        prompt = f"""
        Analyze this file and answer the following query:
        "{query}"
        
        If it's an image of a survivor or ID card, extract:
        - Name
        - Age
        - Skills
        - Bio/Background
        
        Return the result as clear text.
        """
        
        response = model.generate_content([sample_file, prompt])
        
        return {
            "status": "success", 
            "text": response.text,
            "file_uri": sample_file.uri
        }

    except Exception as e:
        logger.error(f"Error extracting from file: {str(e)}")
        return {"status": "error", "error": str(e)}

def save_extracted_info(info: Dict[str, Any]) -> str:
    """
    Save extracted information to the database (mock function).
    
    In a real app, this would write to Spanner/SQL.
    """
    try:
        # Mock saving logic
        logger.info(f"Saving extracted info: {info}")
        return "Successfully saved extracted information to survivor profile."
    except Exception as e:
        return f"Error saving info: {str(e)}"