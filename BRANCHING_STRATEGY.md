# Branching Strategy

## Overview
This document outlines the branching strategy for the Multi-Service Application project. We follow a modified GitFlow approach with the following main branches:

## Main Branches

### `main` (Production)
- Represents the production-ready code
- Always stable and deployable
- Protected branch (requires merge request approval)
- Only accepts merges from `develop` or hotfix branches
- Tagged with semantic versioning (e.g., v1.0.0)

### `develop` (Development)
- Main development branch
- Contains the latest delivered development changes
- Merged into `main` when stable
- Protected branch (requires merge request approval)

## Supporting Branches

### Feature Branches
- Branch from: `develop`
- Merge back into: `develop`
- Naming convention: `feature/description-of-feature`
- Example: `feature/user-authentication`

### Bugfix Branches
- Branch from: `develop`
- Merge back into: `develop`
- Naming convention: `bugfix/description-of-fix`
- Example: `bugfix/login-error-handling`

### Hotfix Branches
- Branch from: `main`
- Merge back into: `main` and `develop`
- Naming convention: `hotfix/description-of-fix`
- Example: `hotfix/security-patch`

### Release Branches
- Branch from: `develop`
- Merge back into: `main` and `develop`
- Naming convention: `release/version-number`
- Example: `release/1.0.0`

## Workflow

1. **Feature Development**:
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/new-feature
   # Make changes
   git commit -m "feat: add new feature"
   git push origin feature/new-feature
   # Create merge request to develop
   ```

2. **Bug Fixes**:
   ```bash
   git checkout develop
   git pull
   git checkout -b bugfix/fix-description
   # Make changes
   git commit -m "fix: resolve bug"
   git push origin bugfix/fix-description
   # Create merge request to develop
   ```

3. **Hotfixes**:
   ```bash
   git checkout main
   git pull
   git checkout -b hotfix/urgent-fix
   # Make changes
   git commit -m "fix: urgent fix for production"
   git push origin hotfix/urgent-fix
   # Create merge requests to main and develop
   ```

4. **Releases**:
   ```bash
   git checkout develop
   git pull
   git checkout -b release/1.0.0
   # Version bump and final testing
   git commit -m "chore: prepare release 1.0.0"
   git push origin release/1.0.0
   # Create merge requests to main and develop
   ```

## Commit Message Convention

We follow the Conventional Commits specification:
- `feat:` for new features
- `fix:` for bug fixes
- `docs:` for documentation changes
- `style:` for formatting changes
- `refactor:` for code refactoring
- `test:` for adding tests
- `chore:` for maintenance tasks

## Version Control Best Practices

1. **Commit Messages**:
   - Be descriptive and concise
   - Use present tense
   - Reference issue numbers when applicable

2. **Code Review**:
   - All changes require at least one reviewer
   - No direct commits to protected branches
   - All tests must pass before merging

3. **Branch Management**:
   - Delete branches after merging
   - Keep branches up to date with their parent
   - Regular cleanup of stale branches

4. **CI/CD Integration**:
   - All branches run the CI pipeline
   - `develop` and `main` branches run the full pipeline
   - Feature branches run tests and linting

## Protected Branches

The following branches are protected:
- `main`
- `develop`

Protection rules:
- Require merge request approvals
- Require status checks to pass
- Require branches to be up to date
- No direct pushes allowed 