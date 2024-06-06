FROM python:3.11-buster

RUN pip3 install --upgrade pip
RUN pip3 install poetry==1.8.3

RUN pip3 install jupyter

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN touch README.md

RUN poetry lock --no-update 
RUN poetry install --no-root && rm -rf $POETRY_CACHE_DIR
RUN poetry install

# Install ipykernel inside the Poetry environment
RUN poetry run pip install ipykernel

# Create a custom Jupyter kernel using the Poetry venv
RUN poetry run python -m ipykernel install --user --name=portal-ai-jupyter

# Add Jupyter Lab to the PATH
ENV PATH="/root/.local/bin:${PATH}"

# Install Java & tesseract
# Install system dependencies
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless tesseract-ocr && \
    rm -rf /var/lib/apt/lists/*

# Add Java to the PATH
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Expose port 8888 for Jupyter Lab
EXPOSE 8889

# Run Jupyter Lab when the container launches
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8889", "--no-browser", "--allow-root"]