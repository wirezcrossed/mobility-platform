# Contributing to Circuit Provider API

Thank you for your interest in contributing to the Circuit Provider API! This document provides guidelines for contributing to this MDS 2.0 compliant provider API implementation.

## Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured
- Python 3.11+
- Git

### Development Setup

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/your-username/circuit-provider-api.git
   cd circuit-provider-api
   ```

2. **Create a development branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Configure environment:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit with your development values
   ```

## Development Guidelines

### Code Standards

- **Python**: Follow PEP 8 style guidelines
- **Terraform**: Use consistent formatting with `terraform fmt`
- **Documentation**: Update relevant documentation for any changes
- **Comments**: Include clear comments for complex logic

### MDS Compliance

- All API changes must maintain MDS 2.0.2 compliance
- Reference the [OMF MDS specification](https://github.com/openmobilityfoundation/mobility-data-specification)
- Test API responses against MDS schema requirements

### Testing

Before submitting changes:

1. **Validate Terraform:**
   ```bash
   terraform validate
   terraform plan
   ```

2. **Test Lambda functions locally:**
   ```bash
   # Test individual functions
   python lambda/vehicles/vehicles.py
   ```

3. **API Testing:**
   ```bash
   # Test endpoints after deployment
   curl https://your-api-url/status
   curl -H "Authorization: Bearer circuit-token-12345" https://your-api-url/vehicles
   ```

## Making Changes

### API Endpoints

When modifying API endpoints:
- Ensure MDS 2.0 compliance
- Update OpenAPI specification
- Test with sample data
- Update documentation

### Infrastructure Changes

For Terraform modifications:
- Follow AWS best practices
- Maintain security standards
- Update variable descriptions
- Test in development environment first

### Lambda Functions

For Lambda function changes:
- Maintain error handling
- Update logging as needed
- Ensure proper JSON responses
- Test with various input scenarios

## Submitting Changes

### Pull Request Process

1. **Create descriptive commits:**
   ```bash
   git add .
   git commit -m "feat: add vehicle filtering by bbox parameter"
   ```

2. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create Pull Request:**
   - Use descriptive title and description
   - Reference any related issues
   - Include testing details
   - Ensure CI checks pass

### Pull Request Template

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Infrastructure change

## Testing
- [ ] Terraform validate passes
- [ ] API endpoints tested
- [ ] MDS compliance verified
- [ ] Documentation updated

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No breaking changes (or clearly documented)
```

## Release Process

### Versioning

We use semantic versioning (SemVer):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers updated
- [ ] Security review completed
- [ ] Deployment tested

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for mistakes
- Prioritize community benefit

### Enforcement

Report any unacceptable behavior to the project maintainers.

## Getting Help

### Resources

- [MDS Specification](https://github.com/openmobilityfoundation/mobility-data-specification)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda Python Runtime](https://docs.aws.amazon.com/lambda/latest/dg/python-programming-model.html)

### Support Channels

- **Issues**: GitHub Issues for bugs and feature requests
- **Discussions**: GitHub Discussions for questions and ideas
- **Documentation**: Check DEPLOYMENT.md and README.md

## Security

### Reporting Security Issues

Do not report security vulnerabilities through public GitHub issues. Instead:

1. Email security concerns to: security@circuit.com
2. Include detailed description of the vulnerability
3. Provide steps to reproduce if possible

### Security Best Practices

- Never commit secrets or credentials
- Use AWS IAM roles with least privilege
- Keep dependencies updated
- Follow secure coding practices

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## Questions?

Feel free to reach out to the maintainers if you have any questions about contributing!