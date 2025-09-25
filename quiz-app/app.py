from flask import Flask, render_template, request, jsonify, session
from werkzeug.utils import secure_filename
import os
import json
import fitz  # PyMuPDF
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)
app.secret_key = os.urandom(24)  # For session management

# Configure OpenAI client
client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

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