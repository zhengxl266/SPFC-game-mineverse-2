// DOM elements
const uploadForm = document.getElementById('upload-form');
const fileInput = document.getElementById('file-input');
const uploadArea = document.querySelector('.upload-area');
const generateBtn = document.getElementById('generate-btn');
const urlForm = document.getElementById('url-form');
const urlInput = document.getElementById('url-input');
const urlSubmitBtn = document.getElementById('url-submit-btn');
const loading = document.getElementById('loading');
const quizContainer = document.getElementById('quiz-container');
const quizForm = document.getElementById('quiz-form');
const quizQuestions = document.getElementById('quiz-questions');
const resultsContainer = document.getElementById('results-container');
const resultsContent = document.getElementById('results-content');
const restartBtn = document.getElementById('restart-btn');

// Global quiz data
let currentQuiz = null;

// Event listeners
uploadForm.addEventListener('submit', handleFileUpload);
urlSubmitBtn.addEventListener('click', handleUrlSubmit);
quizForm.addEventListener('submit', handleQuizSubmit);
restartBtn.addEventListener('click', resetApp);

// File drag and drop
uploadArea.addEventListener('dragover', handleDragOver);
uploadArea.addEventListener('dragleave', handleDragLeave);
uploadArea.addEventListener('drop', handleDrop);

// File input change
fileInput.addEventListener('change', updateFileLabel);

function handleDragOver(e) {
    e.preventDefault();
    uploadArea.classList.add('dragover');
}

function handleDragLeave(e) {
    e.preventDefault();
    uploadArea.classList.remove('dragover');
}

function handleDrop(e) {
    e.preventDefault();
    uploadArea.classList.remove('dragover');
    
    const files = e.dataTransfer.files;
    if (files.length > 0 && files[0].type === 'application/pdf') {
        fileInput.files = files;
        updateFileLabel();
    } else {
        alert('Please drop a PDF file only.');
    }
}

function updateFileLabel() {
    const fileName = fileInput.files[0]?.name;
    if (fileName) {
        const label = document.querySelector('.upload-label');
        label.innerHTML = `<strong>Selected:</strong> ${fileName}`;
    }
}

async function handleUrlSubmit(e) {
    e.preventDefault();
    
    const url = urlInput.value.trim();
    if (!url) {
        alert('Please enter a valid URL.');
        return;
    }

    // Show loading
    showLoading();
    urlSubmitBtn.disabled = true;
    generateBtn.disabled = true;

    try {
        const response = await fetch('/generate-quiz-from-url', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ url: url })
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.error || 'Failed to generate quiz from URL');
        }

        currentQuiz = data;
        displayQuiz(data.quiz);

    } catch (error) {
        console.error('Error generating quiz from URL:', error);
        alert(`Error: ${error.message}`);
        hideLoading();
    } finally {
        urlSubmitBtn.disabled = false;
        generateBtn.disabled = false;
    }
}

async function handleFileUpload(e) {
    e.preventDefault();
    
    const file = fileInput.files[0];
    if (!file) {
        alert('Please select a PDF file.');
        return;
    }
    
    if (file.type !== 'application/pdf') {
        alert('Please select a PDF file only.');
        return;
    }
    
    if (file.size > 10 * 1024 * 1024) { // 10MB limit
        alert('File size must be less than 10MB.');
        return;
    }
    
    // Show loading
    showLoading();
    generateBtn.disabled = true;
    
    try {
        const formData = new FormData();
        formData.append('file', file);
        
        const response = await fetch('/generate-quiz', {
            method: 'POST',
            body: formData
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Failed to generate quiz');
        }
        
        currentQuiz = data;
        displayQuiz(data.quiz);
        
    } catch (error) {
        console.error('Error generating quiz:', error);
        alert('Error generating quiz: ' + error.message);
        resetToUpload();
    }
}

function showLoading() {
    document.getElementById('upload-section').classList.add('hidden');
    loading.classList.remove('hidden');
}

function displayQuiz(questions) {
    loading.classList.add('hidden');
    quizContainer.classList.remove('hidden');
    
    quizQuestions.innerHTML = '';
    
    questions.forEach((question, index) => {
        const questionDiv = document.createElement('div');
        questionDiv.className = 'question';
        
        questionDiv.innerHTML = `
            <h3>Question ${index + 1}</h3>
            <p class="result-question">${question.question}</p>
            <div class="options">
                ${question.options.map((option, optionIndex) => {
                    const letter = String.fromCharCode(65 + optionIndex); // A, B, C, D
                    return `
                        <label class="option">
                            <input type="radio" name="question-${index}" value="${letter}" required>
                            <span>${option}</span>
                        </label>
                    `;
                }).join('')}
            </div>
        `;
        
        quizQuestions.appendChild(questionDiv);
    });
}

async function handleQuizSubmit(e) {
    e.preventDefault();
    
    // Collect answers
    const answers = [];
    const questions = currentQuiz.quiz;
    
    for (let i = 0; i < questions.length; i++) {
        const selectedOption = document.querySelector(`input[name="question-${i}"]:checked`);
        answers.push(selectedOption ? selectedOption.value : null);
    }
    
    // Show loading
    quizContainer.classList.add('hidden');
    showLoading();
    
    try {
        const response = await fetch('/mark-quiz', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ answers })
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Failed to mark quiz');
        }
        
        displayResults(data.results);
        
    } catch (error) {
        console.error('Error marking quiz:', error);
        alert('Error marking quiz: ' + error.message);
        quizContainer.classList.remove('hidden');
        loading.classList.add('hidden');
    }
}

function displayResults(results) {
    loading.classList.add('hidden');
    resultsContainer.classList.remove('hidden');
    
    // Calculate score
    const correctAnswers = results.filter(result => result.is_correct).length;
    const totalQuestions = results.length;
    const percentage = Math.round((correctAnswers / totalQuestions) * 100);
    
    // Create score summary
    const scoreSummary = document.createElement('div');
    scoreSummary.className = 'score-summary';
    scoreSummary.innerHTML = `
        <h3>Your Score: ${correctAnswers}/${totalQuestions} (${percentage}%)</h3>
        <p>${getScoreMessage(percentage)}</p>
    `;
    
    resultsContent.innerHTML = '';
    resultsContent.appendChild(scoreSummary);
    
    // Display each result
    results.forEach((result, index) => {
        const resultDiv = document.createElement('div');
        resultDiv.className = `result-item ${result.is_correct ? 'correct' : 'incorrect'}`;
        
        let answerHtml = '';
        if (result.user_answer) {
            answerHtml = `
                <div class="result-answer">
                    <strong>Your Answer:</strong> 
                    <span class="${result.is_correct ? 'correct' : 'incorrect'}-answer">
                        ${result.user_answer}
                    </span>
                </div>
            `;
        }
        
        if (!result.is_correct) {
            answerHtml += `
                <div class="result-answer">
                    <strong>Correct Answer:</strong> 
                    <span class="correct-answer">${result.correct_answer}</span>
                </div>
            `;
        }
        
        let explanationHtml = '';
        if (result.explanation) {
            explanationHtml = `
                <div class="explanation">
                    <strong>Explanation:</strong><br>
                    ${result.explanation}
                </div>
            `;
        }
        
        resultDiv.innerHTML = `
            <div class="result-question">Question ${index + 1}: ${result.question}</div>
            ${answerHtml}
            ${explanationHtml}
        `;
        
        resultsContent.appendChild(resultDiv);
    });
}

function getScoreMessage(percentage) {
    if (percentage >= 90) return "Excellent work! You have a strong understanding of the material.";
    if (percentage >= 80) return "Great job! You understand most of the key concepts.";
    if (percentage >= 70) return "Good work! Review the explanations to strengthen your understanding.";
    if (percentage >= 60) return "Not bad! There's room for improvement - review the material.";
    return "Keep studying! Review the explanations and try again.";
}

function resetApp() {
    // Reset all containers
    document.getElementById('upload-section').classList.remove('hidden');
    loading.classList.add('hidden');
    quizContainer.classList.add('hidden');
    resultsContainer.classList.add('hidden');
    
    // Reset form
    uploadForm.reset();
    generateBtn.disabled = false;
    
    // Reset file label
    const label = document.querySelector('.upload-label');
    label.innerHTML = '<strong>Choose a PDF file</strong> or drag and drop';
    
    // Clear data
    currentQuiz = null;
}

function resetToUpload() {
    loading.classList.add('hidden');
    document.getElementById('upload-section').classList.remove('hidden');
    generateBtn.disabled = false;
}