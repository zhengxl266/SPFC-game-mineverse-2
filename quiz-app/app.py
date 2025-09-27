from flask import Flask, render_template, request, jsonify, session
from werkzeug.utils import secure_filename
import os
import json
import fitz  # PyMuPDF
from openai import OpenAI
from dotenv import load_dotenv
import httpx
from bs4 import BeautifulSoup

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.secret_key = os.urandom(24)  # For session management

# Configure OpenAI client
try:
    # Create a custom httpx client without the problematic parameters
    custom_http_client = httpx.Client(timeout=30.0)
    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'), http_client=custom_http_client)
except Exception as e:
    print(f"Error creating OpenAI client: {e}")
    # Fallback - try without custom client
    client = None

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'pdf'}

# Ensure upload folder exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    """Check if the uploaded file has an allowed extension."""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def extract_text_from_pdf(pdf_path):
    """Extract text content from a PDF file."""
    try:
        doc = fitz.open(pdf_path)
        text = ""
        for page in doc:
            text += page.get_text()
        doc.close()
        return text
    except Exception as e:
        print(f"Error extracting text from PDF: {e}")
        return None

@app.route('/')
def index():
    """Serve the main page."""
    return render_template('index.html')

@app.route('/generate-quiz', methods=['POST'])
def generate_quiz():
    """Generate a quiz from uploaded PDF content."""
    try:
        # Check if a file was uploaded
        if 'file' not in request.files:
            return jsonify({'error': 'No file uploaded'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Please upload a PDF file.'}), 400
        
        # Save the uploaded file
        filename = secure_filename(file.filename)
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)
        
        # Extract text from PDF
        document_text = extract_text_from_pdf(filepath)
        if not document_text:
            return jsonify({'error': 'Failed to extract text from PDF'}), 500
        
        # Generate quiz using OpenAI
        prompt = f"""Based on the following text, create a 5-question multiple-choice quiz. 
        Each question should have 4 options (A, B, C, D) and test understanding of the key concepts.
        
        Text: {document_text[:4000]}  # Limit text to avoid token limits
        
        Please respond with a JSON object in this exact format:
        {{
            "quiz": [
                {{
                    "question": "Question text here?",
                    "options": ["A. Option 1", "B. Option 2", "C. Option 3", "D. Option 4"],
                    "correct_answer": "A"
                }}
            ]
        }}"""
        
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a helpful teacher creating educational quizzes. Always respond with valid JSON."},
                {"role": "user", "content": prompt}
            ],
            response_format={"type": "json_object"}
        )
        
        quiz_data = json.loads(response.choices[0].message.content)
        
        # Store quiz data and document text in session for later use
        session['quiz_data'] = quiz_data
        session['document_text'] = document_text
        
        # Clean up uploaded file
        os.remove(filepath)
        
        return jsonify(quiz_data)
        
    except Exception as e:
        print(f"Error generating quiz: {e}")
        return jsonify({'error': 'Failed to generate quiz'}), 500

@app.route('/generate-quiz-from-url', methods=['POST'])
def generate_quiz_from_url():
    """Generate a quiz from URL content."""
    try:
        # Get URL from request
        data = request.get_json()
        if not data or 'url' not in data:
            return jsonify({'error': 'No URL provided'}), 400
        
        url = data['url'].strip()
        if not url:
            return jsonify({'error': 'URL cannot be empty'}), 400
        
        # Basic URL validation
        if not (url.startswith('http://') or url.startswith('https://')):
            url = 'https://' + url
        
        # Fetch webpage content
        try:
            response = httpx.get(url, timeout=30.0, follow_redirects=True)
            response.raise_for_status()
        except httpx.RequestError as e:
            return jsonify({'error': f'Failed to fetch URL: {str(e)}'}), 400
        except httpx.HTTPStatusError as e:
            return jsonify({'error': f'HTTP error {e.response.status_code}: {str(e)}'}), 400
        
        # Parse HTML and extract text
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Remove script and style elements
        for script in soup(["script", "style"]):
            script.decompose()
        
        # Extract text from paragraphs and other text elements
        text_elements = soup.find_all(['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'article', 'section', 'div'])
        text_content = ' '.join([elem.get_text().strip() for elem in text_elements if elem.get_text().strip()])
        
        # Fallback to all text if paragraph extraction yields too little content
        if len(text_content) < 200:
            text_content = soup.get_text()
        
        # Clean up text
        text_content = ' '.join(text_content.split())  # Remove extra whitespace
        
        if not text_content or len(text_content) < 100:
            return jsonify({'error': 'Could not extract sufficient text content from the URL'}), 400
        
        # Generate quiz using OpenAI (reuse existing logic)
        prompt = f"""Based on the following text, create a 5-question multiple-choice quiz. 
        Each question should have 4 options (A, B, C, D) and test understanding of the key concepts.
        
        Text: {text_content[:4000]}  # Limit text to avoid token limits
        
        Please respond with a JSON object in this exact format:
        {{
            "quiz": [
                {{
                    "question": "Question text here?",
                    "options": ["A. Option 1", "B. Option 2", "C. Option 3", "D. Option 4"],
                    "correct_answer": "A"
                }}
            ]
        }}"""
        
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a helpful teacher creating educational quizzes. Always respond with valid JSON."},
                {"role": "user", "content": prompt}
            ],
            response_format={"type": "json_object"}
        )
        
        quiz_data = json.loads(response.choices[0].message.content)
        
        # Store quiz data and document text in session for later use
        session['quiz_data'] = quiz_data
        session['document_text'] = text_content
        
        return jsonify(quiz_data)
        
    except Exception as e:
        print(f"Error generating quiz from URL: {e}")
        return jsonify({'error': f'Failed to generate quiz: {str(e)}'}), 500

@app.route('/mark-quiz', methods=['POST'])
def mark_quiz():
    """Mark the quiz and provide AI-generated explanations for incorrect answers."""
    try:
        # Get user answers from request
        user_data = request.get_json()
        user_answers = user_data.get('answers', [])
        
        # Get stored quiz data and document text from session
        quiz_data = session.get('quiz_data')
        document_text = session.get('document_text')
        
        if not quiz_data or not document_text:
            return jsonify({'error': 'Quiz data not found. Please generate a new quiz.'}), 400
        
        quiz_questions = quiz_data['quiz']
        results = []
        
        for i, question_data in enumerate(quiz_questions):
            user_answer = user_answers[i] if i < len(user_answers) else None
            correct_answer = question_data['correct_answer']
            is_correct = user_answer == correct_answer
            
            result = {
                'question': question_data['question'],
                'options': question_data['options'],
                'user_answer': user_answer,
                'correct_answer': correct_answer,
                'is_correct': is_correct,
                'explanation': None
            }
            
            # Generate explanation for incorrect answers
            if not is_correct and user_answer:
                explanation_prompt = f"""Based on the following text and quiz question, explain why the user's answer was incorrect and provide a helpful explanation.

                Original text: {document_text[:2000]}
                
                Question: {question_data['question']}
                Options: {', '.join(question_data['options'])}
                Correct answer: {correct_answer}
                User's answer: {user_answer}
                
                Please provide a concise, helpful explanation for why the user was wrong and what the correct answer means in the context of the text."""
                
                explanation_response = client.chat.completions.create(
                    model="gpt-4o",
                    messages=[
                        {"role": "system", "content": "You are a helpful tutor providing clear, educational explanations."},
                        {"role": "user", "content": explanation_prompt}
                    ],
                    max_tokens=200
                )
                
                result['explanation'] = explanation_response.choices[0].message.content
            
            results.append(result)
        
        return jsonify({'results': results})
        
    except Exception as e:
        print(f"Error marking quiz: {e}")
        return jsonify({'error': 'Failed to mark quiz'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)