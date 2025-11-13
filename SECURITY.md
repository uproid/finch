# Security Policy

## Our Commitment

The Finch framework team takes the security of our software seriously. We appreciate your efforts to responsibly disclose any security vulnerabilities you find and will make every effort to acknowledge your contributions.

## Supported Versions

We provide security updates for the following versions of Finch:

| Version | Supported          | Status                |
| ------- | ------------------ | --------------------- |
| 1.x.x   | :white_check_mark: | Active support        |
| 0.9.x   | :white_check_mark: | Security fixes only   |
| 0.8.x   | :warning:          | Limited support       |
| < 0.8   | :x:                | No longer supported   |

**Note**: We strongly recommend always using the latest stable version to ensure you have all security patches and improvements.

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues, discussions, or pull requests.**

### How to Report

If you discover a security vulnerability, please report it privately using one of these methods:

#### 1. GitHub Security Advisories (Preferred)

1. Go to the [Security tab](https://github.com/uproid/finch/security) of the Finch repository
2. Click on "Report a vulnerability"
3. Fill out the vulnerability details form
4. Submit the report

#### 2. Email

Send an email to: **[INSERT SECURITY EMAIL]**

Use the subject line: `[SECURITY] Brief description of the issue`

#### 3. Encrypted Communication

For highly sensitive security issues, you can use PGP encryption:

* **PGP Key**: [INSERT PGP KEY FINGERPRINT]
* **Public Key**: Available at [INSERT KEY LOCATION]

### What to Include in Your Report

To help us understand and resolve the issue quickly, please include as much of the following information as possible:

1. **Type of vulnerability** (e.g., SQL injection, XSS, authentication bypass, etc.)
2. **Full paths** of source file(s) related to the vulnerability
3. **Location of the affected source code** (tag/branch/commit or direct URL)
4. **Step-by-step instructions** to reproduce the issue
5. **Proof-of-concept or exploit code** (if possible)
6. **Impact assessment** - What could an attacker accomplish?
7. **Affected versions** - Which versions of Finch are impacted?
8. **Suggested fix** (if you have one)
9. **Your name and contact information** for follow-up questions

### Example Report Template

```markdown
## Vulnerability Summary
Brief description of the vulnerability

## Vulnerability Type
[ ] SQL Injection
[ ] Cross-Site Scripting (XSS)
[ ] Authentication/Authorization Issues
[ ] Server-Side Request Forgery (SSRF)
[ ] Path Traversal
[ ] Remote Code Execution
[ ] Denial of Service
[ ] Information Disclosure
[ ] Other: ___________

## Affected Component
Specify the module, file, or function affected

## Affected Versions
Which versions are impacted?

## Severity Assessment
[ ] Critical - Can be exploited remotely with no authentication
[ ] High - Significant impact, requires some user interaction
[ ] Medium - Limited impact or difficult to exploit
[ ] Low - Minimal impact

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Proof of Concept
Provide code or detailed explanation

## Impact
Describe what an attacker could accomplish

## Suggested Remediation
If you have suggestions for fixing the issue

## Additional Information
Any other relevant details
```

## Response Timeline

We are committed to responding to security reports in a timely manner:

| Timeline | Action |
| -------- | ------ |
| **Within 48 hours** | Acknowledge receipt of your vulnerability report |
| **Within 7 days** | Provide an initial assessment and expected timeline |
| **Within 30 days** | Provide a detailed response with either a fix timeline or explanation |
| **Within 90 days** | Aim to release a fix (depending on complexity) |

### What to Expect

1. **Acknowledgment**: We'll confirm receipt of your report within 48 hours
2. **Assessment**: We'll investigate and assess the severity and impact
3. **Communication**: We'll keep you updated on our progress
4. **Fix Development**: We'll work on a patch or mitigation
5. **Disclosure**: We'll coordinate with you on the public disclosure timeline
6. **Credit**: With your permission, we'll acknowledge your contribution

## Disclosure Policy

### Coordinated Disclosure

We follow a coordinated disclosure process:

1. **Private Development**: Security fixes are developed in private
2. **Vendor Notification**: We notify affected parties before public release
3. **Fix Release**: We release the security patch
4. **Public Disclosure**: We publish a security advisory 
5. **Credit**: We credit the reporter (unless they prefer to remain anonymous)

### Disclosure Timeline

* **Standard Timeline**: 90 days from initial report to public disclosure
* **Active Exploitation**: Expedited timeline if the vulnerability is being actively exploited
* **Complex Issues**: Extended timeline for particularly complex vulnerabilities (with mutual agreement)

### Our Commitment

* We will not pursue legal action against security researchers who:
  - Act in good faith
  - Follow this disclosure policy
  - Don't access data beyond what's necessary to demonstrate the vulnerability
  - Don't intentionally harm our users or degrade service
  - Don't publicly disclose the vulnerability before we've had a chance to fix it

## Security Advisories

Published security advisories can be found at:

* **GitHub Security Advisories**: [https://github.com/uproid/finch/security/advisories](https://github.com/uproid/finch/security/advisories)
* **Changelog**: Security fixes are also documented in [CHANGELOG.md](CHANGELOG.md)

Subscribe to security notifications:
1. Watch the repository on GitHub
2. Select "Custom" → Check "Security alerts"

## Security Best Practices for Finch Users

### When Using Finch Framework

#### 1. Keep Dependencies Updated

```yaml
# Always use the latest stable version
dependencies:
  finch: ^1.0.0  # Use caret for automatic minor/patch updates
```

Run regular updates:
```bash
dart pub upgrade
```

#### 2. Secure Configuration

```dart
// Never hardcode sensitive data
// ❌ Bad
final dbPassword = 'myPassword123';

// ✅ Good - Use environment variables
final dbPassword = Platform.environment['DB_PASSWORD'];
```

#### 3. Input Validation

```dart
// Always validate and sanitize user input
import 'package:finch/finch.dart';

class UserController extends Controller {
  Future<Response> createUser(Request request) async {
    // Validate input
    final validator = Validator(request.body);
    validator.rule('email', ['required', 'email']);
    validator.rule('password', ['required', 'min:8']);
    
    if (!validator.validate()) {
      return Response.json({'errors': validator.errors}, 400);
    }
    
    // Process validated data
    // ...
  }
}
```

#### 4. SQL Injection Prevention

```dart
// ✅ Use parameterized queries
final users = await db.query(
  'SELECT * FROM users WHERE email = ?',
  [email]
);

// ❌ Never concatenate user input
// final users = await db.query('SELECT * FROM users WHERE email = "$email"');
```

#### 5. Authentication & Authorization

```dart
// Use Finch's built-in authentication
import 'package:finch/finch.dart';

Route.group('/api', middleware: [AuthMiddleware()], children: [
  Route.get('/profile', UserController.profile),
  Route.post('/update', UserController.update),
]);
```

#### 6. HTTPS/TLS

```dart
// Always use HTTPS in production
final server = await HttpServer.bindSecure(
  'localhost',
  443,
  SecurityContext()
    ..useCertificateChain('path/to/cert.pem')
    ..usePrivateKey('path/to/key.pem'),
);
```

#### 7. CORS Configuration

```dart
// Configure CORS properly
app.use(CorsMiddleware(
  allowedOrigins: ['https://yourdomain.com'],  // Don't use '*' in production
  allowedMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  allowCredentials: true,
));
```

#### 8. Session Security

```dart
// Use secure session configuration
app.sessions(
  secret: Platform.environment['SESSION_SECRET']!,
  secure: true,  // Only send over HTTPS
  httpOnly: true,  // Prevent JavaScript access
  sameSite: 'strict',  // CSRF protection
  maxAge: Duration(hours: 24),
);
```

#### 9. Rate Limiting

```dart
// Implement rate limiting to prevent abuse
Route.group('/api', middleware: [
  RateLimitMiddleware(maxRequests: 100, duration: Duration(minutes: 15))
], children: [
  // Your routes
]);
```

#### 10. Error Handling

```dart
// Don't expose sensitive information in errors
try {
  // Your code
} catch (e) {
  // ❌ Bad - Exposes internal details
  // return Response.json({'error': e.toString()}, 500);
  
  // ✅ Good - Generic error message
  logger.error(e);  // Log internally
  return Response.json({'error': 'An error occurred'}, 500);
}
```

### Security Checklist

Before deploying your Finch application:

- [ ] All dependencies are up to date
- [ ] No hardcoded secrets in source code
- [ ] Environment variables are properly secured
- [ ] HTTPS/TLS is configured
- [ ] Input validation is implemented
- [ ] Parameterized queries are used for database operations
- [ ] Authentication and authorization are properly configured
- [ ] CORS is configured with specific origins (not `*`)
- [ ] Rate limiting is implemented
- [ ] Error messages don't expose sensitive information
- [ ] Security headers are configured (CSP, X-Frame-Options, etc.)
- [ ] File upload validation is implemented (if applicable)
- [ ] SQL injection protection is in place
- [ ] XSS prevention measures are implemented
- [ ] CSRF protection is enabled
- [ ] Logging is configured (but doesn't log sensitive data)

## Known Security Considerations

### Framework Limitations

1. **Database Drivers**: Security depends on the underlying database driver used
2. **Template Engine**: User input in templates must be properly escaped
3. **File Uploads**: Implement proper validation and storage practices
4. **WebSocket Security**: Additional security measures needed for WebSocket connections

### Third-Party Dependencies

The Finch framework relies on various Dart packages. Security of these dependencies is monitored, but users should:

* Regularly run `dart pub outdated` to check for updates
* Review security advisories for dependencies
* Use `dart pub audit` when available

## Security Tools and Resources

### Recommended Tools

* **Dart Analyzer**: Run `dart analyze` to detect potential issues
* **Dependency Checker**: Use `dart pub outdated` regularly
* **SAST Tools**: Static Application Security Testing tools for Dart
* **OWASP ZAP**: For dynamic security testing

### Useful Resources

* [OWASP Top 10](https://owasp.org/www-project-top-ten/)
* [Dart Security Guidelines](https://dart.dev/guides/security)
* [CWE - Common Weakness Enumeration](https://cwe.mitre.org/)
* [CVE - Common Vulnerabilities and Exposures](https://cve.mitre.org/)

## Security Hall of Fame

We appreciate the security researchers who have helped make Finch more secure:

<!-- This section will be updated as security researchers contribute -->

* *[To be added as vulnerabilities are responsibly disclosed]*

**Want to be listed here?** Report a valid security vulnerability following our responsible disclosure policy.

## Contact

For security-related questions that are not vulnerability reports:

* **General Security Questions**: Open a GitHub Discussion
* **Security Team Email**: [INSERT SECURITY EMAIL]
* **Project Maintainers**: See [CONTRIBUTING.md](CONTRIBUTING.md)

## Updates to This Policy

This security policy may be updated from time to time. Significant changes will be announced through:

* GitHub repository announcements
* Release notes
* Project communication channels

**Last Updated**: November 12, 2025  
**Version**: 1.0

---

## Quick Links

* [Report a Vulnerability](https://github.com/uproid/finch/security/advisories/new)
* [View Security Advisories](https://github.com/uproid/finch/security/advisories)
* [Code of Conduct](CODE_OF_CONDUCT.md)
* [Contributing Guidelines](CONTRIBUTING.md)

---

Thank you for helping keep Finch and its users safe! 🔒
