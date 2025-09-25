#!/usr/bin/env python3
"""
Quiz App Setup Test Script
Tests if all dependencies are properly installed and the app can start.
"""

import sys

def test_imports():
    """Test if all required packages can be imported."""
    print("Testing imports...")
    try:
        import flask
        print(f"✅ Flask {flask.__version__}")
    except ImportError as e:
        print(f"❌ Flask: {e}")
        return False
        
    try:
        import fitz  # PyMuPDF
        print(f"✅ PyMuPDF (fitz)")
    except ImportError as e:
        print(f"❌ PyMuPDF: {e}")
        return False
        
    try:
        from dotenv import load_dotenv
        print(f"✅ python-dotenv")
    except ImportError as e:
        print(f"❌ python-dotenv: {e}")
        return False
        
    try:
        import openai
        print(f"✅ OpenAI {openai.__version__}")
    except ImportError as e:
        print(f"❌ OpenAI: {e}")
        return False
        
    return True

def test_env_file():
    """Test if .env file exists."""
    import os
    print("\nTesting environment setup...")
    if os.path.exists('.env'):
        print("✅ .env file exists")
        with open('.env', 'r') as f:
            content = f.read()
            if 'OPENAI_API_KEY' in content:
                print("✅ OPENAI_API_KEY found in .env")
                if 'your_openai_api_key_here' in content:
                    print("⚠️  API key is still placeholder - needs to be replaced with actual key")
                else:
                    print("✅ API key appears to be configured")
            else:
                print("❌ OPENAI_API_KEY not found in .env")
        return True
    else:
        print("❌ .env file not found")
        return False

def test_app_startup():
    """Test if the app can start without errors."""
    print("\nTesting app startup...")
    try:
        # Import the app without running it
        sys.path.insert(0, '.')
        import app
        print("✅ App imports successfully")
        print("✅ Flask app created")
        return True
    except Exception as e:
        print(f"❌ App startup failed: {e}")
        return False

def main():
    print("Quiz App Setup Test")
    print("=" * 30)
    
    all_passed = True
    all_passed &= test_imports()
    all_passed &= test_env_file()
    all_passed &= test_app_startup()
    
    print("\n" + "=" * 30)
    if all_passed:
        print("🎉 All tests passed! Quiz app is ready to run.")
        print("\nTo start the app:")
        print("  python3 app.py")
        print("\nThen open: http://localhost:5000")
    else:
        print("❌ Some tests failed. Check the output above.")
    
    return 0 if all_passed else 1

if __name__ == "__main__":
    exit(main())
