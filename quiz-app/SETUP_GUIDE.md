# Quiz App Setup Guide

## ✅ Dependencies Installed
All required Python dependencies have been successfully installed:
- Flask==2.3.3
- openai==1.3.0 
- python-dotenv==1.0.0
- PyMuPDF==1.23.18

## ✅ Application Status
The quiz application is ready to run! The web interface loads correctly and all core functionality is in place.

## 🔧 OpenAI API Key Configuration

### Current Status
The application will start and run without errors, but quiz generation requires a valid OpenAI API key.

### To Add Your OpenAI API Key:
1. Edit the `.env` file in the quiz-app directory
2. Replace `your_openai_api_key_here` with your actual OpenAI API key:
   ```
   OPENAI_API_KEY=sk-your-actual-openai-api-key-goes-here
   ```

### To Get an OpenAI API Key:
1. Go to https://platform.openai.com/api-keys
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy the key and paste it in the `.env` file

## 🚀 Running the Application

### Method 1: Full Flask Application (Recommended)
```bash
cd quiz-app
python3 app.py
```
Then open http://localhost:5000 in your browser

### Method 2: Simple Demo Version (No API key needed)
```bash
cd quiz-app  
python3 simple_app.py
```
Then open http://localhost:5002 in your browser

## 🧪 Testing

### Health Check
Visit http://localhost:5000/health to see the application status:
- `status`: Shows if the app is running
- `openai_client`: Shows if OpenAI client is initialized  
- `api_key_configured`: Shows if API key is properly set

### Features Available Without API Key:
- ✅ Web interface loads and displays correctly
- ✅ File upload form works
- ✅ PDF file validation 
- ❌ Quiz generation (requires valid OpenAI API key)
- ❌ AI explanations (requires valid OpenAI API key)

### Features Available With API Key:
- ✅ All of the above, plus:
- ✅ Automatic quiz generation from PDF content
- ✅ AI-powered explanations for incorrect answers
- ✅ Full interactive quiz experience

## 📁 File Structure
```
quiz-app/
├── app.py                 # Main Flask application  
├── simple_app.py          # Demo version without external dependencies
├── requirements.txt       # Python dependencies (✅ installed)
├── .env                   # Environment variables (⚠️ needs API key)
├── .env.example          # Template for environment variables
├── README.md             # Detailed documentation
├── SETUP_GUIDE.md        # This setup guide
├── templates/
│   ├── index.html        # Main web interface
│   └── index_standalone.html # Standalone version for simple_app
└── static/
    ├── css/style.css     # Application styles
    └── js/app.js         # Frontend JavaScript
```

## 🛠️ Troubleshooting

### OpenAI Client Issues
If you see "Client.__init__() got an unexpected keyword argument 'proxies'", this is a known compatibility issue. The application has been modified to handle this gracefully and will still run.

### File Upload Issues  
- Ensure uploaded files are PDF format only
- Maximum file size is 10MB
- Check that the uploads/ directory is created (done automatically)

### API Key Issues
- Make sure there are no extra spaces around the API key in .env
- Ensure the API key starts with 'sk-'
- Check that you have credits available in your OpenAI account