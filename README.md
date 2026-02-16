# Mini Project Docker

## Stack
- Node.js
- PostgreSQL
- Docker & Docker Compose

## Run
docker-compose up --build

## Security
- Multi-stage build
- Non-root container
- Scanned with Trivy


# Mini-Project 4 – CI Quality Gate 🚦

This project demonstrates a simple CI pipeline using GitHub Actions.

## 🔧 Tools Used
- Node.js
- ESLint
- GitHub Actions

##  What the pipeline does
- Installs dependencies
- Runs ESLint (linting)
- Runs tests

If ESLint fails, the pipeline turns RED and the merge is blocked.

##  Example
- Unused variable → ❌ CI fails
- Clean code → ✅ CI passes

## 📁 Project Structure
- app.js
- .github/workflows/ci.yml
- .eslintrc.json
