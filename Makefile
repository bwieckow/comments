.PHONY: setup test-post test-get clean help

# Variables
VENV_DIR = venv
PYTHON = $(VENV_DIR)/bin/python
PIP = $(VENV_DIR)/bin/pip
PYTHON_VERSION = python3

# Default target
help:
	@echo "Available targets:"
	@echo "  make setup      - Create virtual environment and install dependencies"
	@echo "  make test-post  - Test POST endpoint with sample event"
	@echo "  make test-get   - Test GET endpoint with sample event"
	@echo "  make clean      - Remove virtual environment and cache files"

# Setup virtual environment and install dependencies
setup:
	@echo "Creating virtual environment..."
	$(PYTHON_VERSION) -m venv $(VENV_DIR)
	@echo "Installing dependencies..."
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	@echo "Setup complete! Virtual environment created at $(VENV_DIR)"
	@echo "To activate: source $(VENV_DIR)/bin/activate"

# Test POST endpoint
test-post: $(VENV_DIR)
	@echo "Testing POST endpoint..."
	@if [ ! -f src/post_event.json ]; then \
		echo "Creating sample post_event.json..."; \
		echo '{"body": "{\\\"comment_text\\\": \\\"This is a great service!\\\", \\\"id_token\\\": \\\"your_google_id_token\\\", \\\"rating\\\": 5}", "requestContext": {"http": {"method": "POST"}}}' > src/post_event.json; \
	fi
	@echo "Note: Make sure DYNAMODB_TABLE_NAME environment variable is set"
	@echo "Running test..."
	$(PYTHON) -c 'import json; import src.comment as comment; event = json.load(open("src/post_event.json")); print(json.dumps(comment.lambda_handler(event, None), indent=2))'

# Test GET endpoint
test-get: $(VENV_DIR)
	@echo "Testing GET endpoint..."
	@if [ ! -f src/get_event.json ]; then \
		echo "Creating sample get_event.json..."; \
		echo '{"queryStringParameters": {"start_date": "2026-01-01T00:00:00", "end_date": "2026-12-31T23:59:59"}, "requestContext": {"http": {"method": "GET"}}}' > src/get_event.json; \
	fi
	@echo "Note: Make sure DYNAMODB_TABLE_NAME environment variable is set"
	@echo "Running test..."
	$(PYTHON) -c 'import json; import src.comment as comment; event = json.load(open("src/get_event.json")); print(json.dumps(comment.lambda_handler(event, None), indent=2))'

# Check if virtual environment exists
$(VENV_DIR):
	@echo "Virtual environment not found. Please run 'make setup' first."
	@exit 1

# Clean up
clean:
	@echo "Cleaning up..."
	rm -rf $(VENV_DIR)
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	@echo "Clean complete!"
