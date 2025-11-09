# Deployment Checklist

Use this checklist before deploying to production or publishing to npm.

## Pre-Deployment Testing

### Local Testing
- [ ] All scripts are executable
- [ ] Test suite passes (`npm test`)
- [ ] Shell scripts have valid syntax
- [ ] No hardcoded credentials in code
- [ ] .gitignore excludes sensitive files
- [ ] Documentation is complete and accurate

### Multi-Distribution Testing
- [ ] Test on Ubuntu 22.04 LTS
- [ ] Test on Debian 11
- [ ] Test on CentOS 8 / Rocky Linux
- [ ] Test on Fedora (latest)
- [ ] Test on Raspberry Pi OS (optional)

### IdP Testing
- [ ] Test Auth0 integration
- [ ] Test Okta integration (if available)
- [ ] Test Azure AD integration (if available)
- [ ] Test Google Workspace integration (if available)
- [ ] Test Keycloak integration (if available)
- [ ] Test generic OIDC integration

### Security Testing
- [ ] SSL certificate generation works
- [ ] HTTPS redirect functions properly
- [ ] Security headers are present
- [ ] Firewall rules are applied
- [ ] Fail2ban is configured
- [ ] OAuth2 authentication works
- [ ] Session management is secure
- [ ] Run basic security audit

## Documentation Review

### Content Completeness
- [ ] README.md is complete
- [ ] INSTALLATION.md has clear instructions
- [ ] IDP_SETUP.md covers all providers
- [ ] SSL_MANAGEMENT.md is comprehensive
- [ ] CONTRIBUTING.md has clear guidelines
- [ ] CHANGELOG.md is up to date
- [ ] All code comments are accurate

### Documentation Quality
- [ ] No spelling errors
- [ ] No broken links
- [ ] Examples are accurate
- [ ] Commands are tested
- [ ] Screenshots are clear (if any)
- [ ] Code blocks are formatted correctly

## Code Quality

### Code Standards
- [ ] Consistent indentation (4 spaces)
- [ ] Meaningful variable names
- [ ] Proper error handling
- [ ] Functions are well-documented
- [ ] No unused code
- [ ] No debug statements left in code

### Security Review
- [ ] No credentials in code
- [ ] All inputs are validated
- [ ] Error messages don't leak sensitive info
- [ ] File permissions are correct
- [ ] Services run with minimal privileges

## Repository Setup

### GitHub Configuration
- [ ] Create GitHub repository
- [ ] Push all code to GitHub
- [ ] Set up branch protection (main/master)
- [ ] Create issue templates
- [ ] Create PR template
- [ ] Add repository description
- [ ] Add topics/tags
- [ ] Create SECURITY.md
- [ ] Enable Discussions (optional)
- [ ] Set up GitHub Actions for CI/CD (optional)

### Repository Files
- [ ] README.md with badges
- [ ] LICENSE file
- [ ] .gitignore
- [ ] CONTRIBUTING.md
- [ ] CODE_OF_CONDUCT.md (optional)
- [ ] SECURITY.md (for vulnerability reporting)

## NPM Package Configuration

### package.json Review
- [ ] Correct package name
- [ ] Appropriate version number
- [ ] Accurate description
- [ ] Correct repository URL
- [ ] Author information updated
- [ ] Keywords are relevant
- [ ] Dependencies are accurate
- [ ] Bin scripts are correct
- [ ] License is specified

### NPM Publication
- [ ] Have npm account
- [ ] Logged into npm (`npm login`)
- [ ] Package name is available
- [ ] Package builds correctly
- [ ] README displays correctly on npm
- [ ] Version follows semver

## Pre-Launch

### Final Checks
- [ ] All tests pass
- [ ] Documentation is accurate
- [ ] No TODO or FIXME in production code
- [ ] Version numbers are consistent
- [ ] Git tags are created
- [ ] Release notes are prepared

### Communication Prep
- [ ] Announcement blog post drafted
- [ ] Social media posts prepared
- [ ] Community outreach planned
- [ ] Support channels ready

## Deployment Steps

### 1. Final Code Review
```bash
# Run tests
npm test

# Check for sensitive data
git log --all --full-history --source --remotes -- **/*.sh **/*.md

# Verify .gitignore
git status --ignored
```

### 2. Create Release
```bash
# Tag the release
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push with tags
git push origin master --tags
```

### 3. Publish to npm
```bash
# Login to npm
npm login

# Publish package
npm publish --access public

# Verify publication
npm view opencode-web-service
```

### 4. Create GitHub Release
- [ ] Go to GitHub Releases
- [ ] Create new release from tag
- [ ] Add release notes from CHANGELOG.md
- [ ] Attach any binary files (if needed)
- [ ] Publish release

## Post-Deployment

### Monitoring
- [ ] Monitor GitHub issues
- [ ] Watch npm downloads
- [ ] Check social media mentions
- [ ] Review user feedback

### Support
- [ ] Respond to issues promptly
- [ ] Update documentation as needed
- [ ] Fix critical bugs immediately
- [ ] Plan next release

### Marketing (Optional)
- [ ] Post on Reddit (r/selfhosted, r/webdev, etc.)
- [ ] Submit to Hacker News
- [ ] Post on Product Hunt
- [ ] Share on Twitter/LinkedIn
- [ ] Write blog post
- [ ] Create demo video

## Rollback Plan

If issues are discovered:

### Quick Fixes
```bash
# Unpublish from npm (within 72 hours)
npm unpublish opencode-web-service@1.0.0

# Or deprecate
npm deprecate opencode-web-service@1.0.0 "Please use version 1.0.1"
```

### For Critical Issues
1. Create hotfix branch
2. Fix the issue
3. Test thoroughly
4. Publish patch version (1.0.1)
5. Update documentation
6. Notify users

## Long-term Maintenance

### Regular Tasks
- [ ] Monitor security advisories
- [ ] Update dependencies monthly
- [ ] Review and merge PRs weekly
- [ ] Respond to issues within 48 hours
- [ ] Release patches as needed
- [ ] Update documentation quarterly

### Version Planning
- **Patch (1.0.x)**: Bug fixes, security updates
- **Minor (1.x.0)**: New features, improvements
- **Major (x.0.0)**: Breaking changes, major refactors

---

## Notes

Add any additional notes or considerations specific to your deployment:

---

**Deployment Date**: ___________
**Deployed By**: ___________
**Version**: ___________
**Status**: [ ] Ready [ ] Blocked [ ] In Progress
**Blockers**: ___________

---

**Last Updated**: November 2025
