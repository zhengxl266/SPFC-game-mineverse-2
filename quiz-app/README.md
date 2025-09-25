# AI Quiz Generator and Tutor

A web application that automatically generates interactive quizzes from PDF documents using OpenAI's GPT-4o model. The application provides AI-powered explanations for incorrect answers, acting as an automated tutor.

## Features

- **PDF Upload**: Upload study materials, lecture notes, or any educational PDF
- **AI Quiz Generation**: Automatically generates 5 multiple-choice questions using GPT-4o
- **Interactive Interface**: Clean, responsive web interface with drag-and-drop file upload
- **Intelligent Marking**: Compares user answers with correct answers
- **AI Tutoring**: Provides personalized explanations for incorrect answers using the original document context
- **Score Analysis**: Shows detailed results with performance feedback

## Setup Instructions

### Prerequisites

- Python 3.8 or higher
- OpenAI API key

### Installation

1. Navigate to the quiz-app directory:
   ```bash
   cd quiz-app
   ```

2. Install required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Create a `.env` file and add your OpenAI API key:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and replace `your_openai_api_key_here` with your actual OpenAI API key.

4. Run the application:
   ```bash
   python app.py
   ```

5. Open your browser and go to `http://localhost:5000`

## Usage

1. **Upload PDF**: Click "Choose a PDF file" or drag and drop a PDF document
2. **Generate Quiz**: Click "Generate Quiz" and wait for the AI to create questions
3. **Take Quiz**: Answer the 5 multiple-choice questions
4. **Review Results**: See your score and read AI explanations for any incorrect answers
5. **Repeat**: Click "Take Another Quiz" to upload a new document

## Technical Architecture

### Backend (Flask)
- **File Upload**: Handles PDF file uploads with security validation
- **Text Extraction**: Uses PyMuPDF to extract text from PDF documents
- **Quiz Generation**: Integrates with OpenAI GPT-4o using JSON mode for structured responses
- **Answer Marking**: Compares user responses with correct answers
- **AI Explanations**: Generates contextual explanations for incorrect answers

### Frontend (HTML/CSS/JavaScript)
- **Responsive Design**: Works on desktop and mobile devices
- **Interactive UI**: Dynamic quiz rendering and results display
- **File Handling**: Drag-and-drop support with file validation
- **AJAX Communication**: Seamless communication with backend using fetch API

### API Endpoints

- `GET /`: Serves the main application page
- `POST /generate-quiz`: Accepts PDF upload and returns generated quiz JSON
- `POST /mark-quiz`: Accepts user answers and returns marked results with explanations

## File Structure

```
quiz-app/
├── app.py                 # Main Flask application
├── requirements.txt       # Python dependencies
├── .env.example          # Environment variables template
├── README.md             # This file
├── templates/
│   └── index.html        # Main HTML template
├── static/
│   ├── css/
│   │   └── style.css     # Application styles
│   └── js/
│       └── app.js        # Frontend JavaScript
└── uploads/              # Temporary file storage (excluded from git)
```

## Security Features

- File type validation (PDF only)
- File size limits (10MB maximum)
- Secure filename handling
- Temporary file cleanup
- Session-based data storage

## Error Handling

- Invalid file type detection
- PDF text extraction errors
- OpenAI API error handling
- Network connectivity issues
- User-friendly error messages

## Dependencies

- **Flask**: Web framework
- **OpenAI**: AI model integration
- **PyMuPDF**: PDF text extraction
- **python-dotenv**: Environment variable management
- **Werkzeug**: File upload security utilities