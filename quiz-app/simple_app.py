#!/usr/bin/env python3
"""
AI Quiz Generator and Tutor - Simplified Demo Version
A simple HTTP server demonstrating the quiz application concept.
This version shows the structure without external dependencies.
"""

import http.server
import socketserver
import json
import os
import sys
from urllib.parse import urlparse, parse_qs
import cgi
import io

PORT = 5002

class QuizHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler for the quiz application"""
    
    def __init__(self, *args, **kwargs):
        # Change to the templates directory for serving static files
        super().__init__(*args, directory="/home/runner/work/SPFC-game-mineverse-2/SPFC-game-mineverse-2/quiz-app", **kwargs)
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/' or self.path == '/index.html':
            self.serve_index()
        elif self.path.startswith('/static/'):
            self.serve_static_file()
        else:
            self.send_error(404)
    
    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/generate-quiz':
            self.handle_generate_quiz()
        elif self.path == '/mark-quiz':
            self.handle_mark_quiz()
        else:
            self.send_error(404)
    
    def serve_index(self):
        """Serve the main HTML page"""
        try:
            # Use standalone version with embedded CSS/JS
            with open('templates/index_standalone.html', 'r') as f:
                content = f.read()
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(content.encode())
        except FileNotFoundError:
            self.send_error(404, "HTML template not found")
    
    def serve_static_file(self):
        """Serve static files (CSS, JS)"""
        try:
            # Remove /static/ from path and get the file
            file_path = self.path[8:]  # Remove '/static/'
            full_path = os.path.join('static', file_path)
            
            if not os.path.exists(full_path):
                self.send_error(404, "File not found")
                return
            
            # Determine content type
            if file_path.endswith('.css'):
                content_type = 'text/css'
            elif file_path.endswith('.js'):
                content_type = 'application/javascript'
            else:
                content_type = 'text/plain'
            
            with open(full_path, 'r') as f:
                content = f.read()
            
            self.send_response(200)
            self.send_header('Content-type', content_type)
            self.end_headers()
            self.wfile.write(content.encode())
            
        except Exception as e:
            print(f"Error serving static file: {e}")
            self.send_error(500, "Error serving static file")
    
    def handle_generate_quiz(self):
        """Handle quiz generation (demo version)"""
        try:
            # For demo purposes, return a sample quiz regardless of file upload
            sample_quiz = {
                "quiz": [
                    {
                        "question": "What is artificial intelligence?",
                        "options": [
                            "A. A computer program that mimics human intelligence",
                            "B. A type of robot",
                            "C. A programming language",
                            "D. A database system"
                        ],
                        "correct_answer": "A"
                    },
                    {
                        "question": "Which of the following is a machine learning technique?",
                        "options": [
                            "A. HTML",
                            "B. Neural networks",
                            "C. CSS",
                            "D. JavaScript"
                        ],
                        "correct_answer": "B"
                    },
                    {
                        "question": "What does PDF stand for?",
                        "options": [
                            "A. Personal Document Format",
                            "B. Portable Document Format",
                            "C. Public Data File",
                            "D. Print Document File"
                        ],
                        "correct_answer": "B"
                    },
                    {
                        "question": "Which programming language is commonly used for web development?",
                        "options": [
                            "A. Assembly",
                            "B. COBOL",
                            "C. JavaScript",
                            "D. Fortran"
                        ],
                        "correct_answer": "C"
                    },
                    {
                        "question": "What is the primary purpose of a quiz application?",
                        "options": [
                            "A. Entertainment only",
                            "B. Testing knowledge and providing feedback",
                            "C. Data storage",
                            "D. Image processing"
                        ],
                        "correct_answer": "B"
                    }
                ]
            }
            
            self.send_json_response(sample_quiz)
            
        except Exception as e:
            print(f"Error in generate_quiz: {e}")
            self.send_json_error(500, "Failed to generate quiz")
    
    def handle_mark_quiz(self):
        """Handle quiz marking (demo version)"""
        try:
            # Read the JSON data
            content_length = int(self.headers.get('content-length', 0))
            if content_length == 0:
                self.send_json_error(400, "No data provided")
                return
            
            post_data = self.rfile.read(content_length).decode('utf-8')
            data = json.loads(post_data)
            user_answers = data.get('answers', [])
            
            # Sample correct answers (should match the quiz above)
            correct_answers = ['A', 'B', 'B', 'C', 'B']
            
            # Sample explanations for wrong answers
            explanations = {
                0: "AI refers to computer systems that can perform tasks that typically require human intelligence, such as learning, reasoning, and problem-solving.",
                1: "Neural networks are a fundamental machine learning technique inspired by the human brain's structure and function.",
                2: "PDF stands for Portable Document Format, a file format developed by Adobe for presenting documents consistently across different platforms.",
                3: "JavaScript is widely used for web development, enabling interactive and dynamic web pages.",
                4: "Quiz applications are designed to test knowledge and provide educational feedback to help users learn."
            }
            
            # Generate results
            results = []
            sample_questions = [
                "What is artificial intelligence?",
                "Which of the following is a machine learning technique?", 
                "What does PDF stand for?",
                "Which programming language is commonly used for web development?",
                "What is the primary purpose of a quiz application?"
            ]
            
            for i, user_answer in enumerate(user_answers):
                if i < len(correct_answers):
                    is_correct = user_answer == correct_answers[i]
                    result = {
                        "question": sample_questions[i] if i < len(sample_questions) else f"Sample question {i + 1}",
                        "options": [f"Option {j}" for j in range(4)],
                        "user_answer": user_answer,
                        "correct_answer": correct_answers[i],
                        "is_correct": is_correct,
                        "explanation": explanations.get(i) if not is_correct else None
                    }
                    results.append(result)
            
            response_data = {"results": results}
            self.send_json_response(response_data)
            
        except Exception as e:
            print(f"Error in mark_quiz: {e}")
            self.send_json_error(500, "Failed to mark quiz")
    
    def send_json_response(self, data):
        """Send a JSON response"""
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        response = json.dumps(data).encode()
        self.wfile.write(response)
    
    def send_json_error(self, code, message):
        """Send a JSON error response"""
        self.send_response(code)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        error_data = {"error": message}
        response = json.dumps(error_data).encode()
        self.wfile.write(response)

def main():
    """Start the server"""
    try:
        with socketserver.TCPServer(("", PORT), QuizHandler) as httpd:
            print(f"AI Quiz Generator Demo Server running at http://localhost:{PORT}")
            print("This is a simplified demo version showing the application structure.")
            print("For full functionality, install the requirements and use app.py with Flask.")
            print("Press Ctrl+C to stop the server")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
    except Exception as e:
        print(f"Error starting server: {e}")

if __name__ == "__main__":
    # Change to the quiz-app directory
    quiz_app_dir = "/home/runner/work/SPFC-game-mineverse-2/SPFC-game-mineverse-2/quiz-app"
    if os.path.exists(quiz_app_dir):
        os.chdir(quiz_app_dir)
    main()