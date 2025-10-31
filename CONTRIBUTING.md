# Contributing to Rabbit Forms

First off, thank you for considering contributing to Rabbit Forms! It's people like you that make Rabbit Forms such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by our commitment to fostering an open and welcoming environment. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title** for the issue
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** to demonstrate the steps
- **Describe the behavior you observed** and what behavior you expected to see
- **Include screenshots** if possible
- **Include your environment details**: OS, browser, Node version, etc.

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful** to most users
- **List any similar features** in other form builders you know

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Write tests** if you've added code that should be tested
4. **Ensure the test suite passes** (`npm test`)
5. **Make sure your code lints** (`npm run lint`)
6. **Update documentation** if needed
7. **Create a pull request** with a clear title and description

## Development Setup

### Prerequisites

- Node.js 18+
- npm/pnpm/yarn
- Supabase account
- Git

### Local Setup

```bash
# Clone your fork
git clone https://github.com/your-username/rabbit-forms.git
cd rabbit-forms

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local

# Set up Supabase (see README.md)
# Then start the dev server
npm run dev
```

### Project Structure

```
src/
├── app/              # Next.js App Router pages
├── components/       # React components
├── lib/              # Utilities and helpers
└── types/            # TypeScript type definitions
```

### Coding Standards

#### TypeScript

- Use TypeScript for all new files
- Define proper types and interfaces
- Avoid `any` types unless absolutely necessary
- Use meaningful variable and function names

#### React Components

- Use functional components with hooks
- Keep components small and focused
- Use proper TypeScript types for props
- Follow the component structure:

```typescript
import { useState } from 'react';

interface MyComponentProps {
  title: string;
  onSubmit: (data: string) => void;
}

export function MyComponent({ title, onSubmit }: MyComponentProps) {
  const [value, setValue] = useState('');

  return (
    <div>
      <h1>{title}</h1>
      {/* Component JSX */}
    </div>
  );
}
```

#### File Naming

- Components: PascalCase (e.g., `FormBuilder.tsx`)
- Utilities: camelCase (e.g., `exportCsv.ts`)
- Types: PascalCase (e.g., `FormSchema.ts`)

#### Styling

- Use Tailwind CSS utility classes
- Follow mobile-first responsive design
- Use shadcn/ui components when possible
- Keep custom CSS minimal

### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
feat: add signature field support
fix: resolve duplicate submission bug
docs: update API documentation
style: format code with prettier
refactor: simplify conditional logic engine
test: add tests for form builder
chore: update dependencies
```

### Branch Naming

- Feature: `feature/description` (e.g., `feature/signature-field`)
- Bug fix: `fix/description` (e.g., `fix/duplicate-check`)
- Documentation: `docs/description`
- Refactor: `refactor/description`

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- FormBuilder.test.tsx

# Run E2E tests
npm run test:e2e
```

### Writing Tests

- Write unit tests for utilities and hooks
- Write component tests for UI components
- Write integration tests for critical flows
- Use meaningful test descriptions

Example:

```typescript
import { render, screen } from '@testing-library/react';
import { FormBuilder } from './FormBuilder';

describe('FormBuilder', () => {
  it('should render field palette', () => {
    render(<FormBuilder />);
    expect(screen.getByText('Text Field')).toBeInTheDocument();
  });

  it('should add field to canvas on drag and drop', () => {
    // Test implementation
  });
});
```

## Documentation

- Update README.md if you change functionality
- Add JSDoc comments to public APIs
- Update the implementation plan for major changes
- Add examples for new features

## Pull Request Process

1. **Update tests** - Ensure all tests pass
2. **Update docs** - Keep documentation in sync
3. **Check linting** - Run `npm run lint`
4. **Describe changes** - Write a clear PR description
5. **Link issues** - Reference related issues (e.g., "Fixes #123")
6. **Request review** - Tag maintainers for review
7. **Address feedback** - Respond to review comments
8. **Merge** - Once approved, maintainers will merge

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
```

## Feature Development Workflow

### Major Features

For major features (e.g., new form field types, analytics dashboard):

1. **Create an issue** describing the feature
2. **Discuss the approach** with maintainers
3. **Get approval** before starting work
4. **Create a feature branch**
5. **Develop in small commits**
6. **Write tests**
7. **Update documentation**
8. **Submit PR**

### Minor Features/Fixes

For minor changes (e.g., bug fixes, small improvements):

1. **Create an issue** (optional for very small fixes)
2. **Create a branch**
3. **Make changes**
4. **Submit PR**

## Community

- **GitHub Discussions**: Ask questions, share ideas
- **GitHub Issues**: Report bugs, request features
- **Pull Requests**: Contribute code

## Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- GitHub contributors page

## Questions?

Feel free to ask questions by:

- Opening a GitHub Discussion
- Commenting on an issue
- Reaching out to maintainers

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Rabbit Forms! 🐰
