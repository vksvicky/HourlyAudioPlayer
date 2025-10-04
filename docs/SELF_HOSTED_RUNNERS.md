# Self-Hosted Runners for macOS 12 Testing

## Overview

Since GitHub Actions no longer provides macOS 12 (Monterey) runners, you need to set up self-hosted runners to test your app on macOS 12, which is the minimum supported version.

**Note**: The macOS 12 job is currently disabled in the workflow (`if: false`) to prevent hanging when no self-hosted runners are available. To enable it, set up self-hosted runners and remove the `if: false` condition.

## Setting Up Self-Hosted macOS 12 Runners

### Prerequisites

- A Mac running macOS 12.0 or later
- Administrator access to the machine
- Network access to GitHub

### Steps

1. **Go to Repository Settings**
   - Navigate to your repository on GitHub
   - Go to Settings → Actions → Runners

2. **Add New Runner**
   - Click "New self-hosted runner"
   - Select "macOS" and "x64" architecture
   - Follow the setup instructions provided by GitHub

3. **Install and Configure**
   ```bash
   # Create a folder
   mkdir actions-runner && cd actions-runner
   
   # Download the latest runner package
   curl -o actions-runner-osx-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz
   
   # Extract the installer
   tar xzf ./actions-runner-osx-x64-2.311.0.tar.gz
   
   # Configure the runner (replace with your token and URL)
   ./config.sh --url https://github.com/your-username/HourlyAudioPlayer --token YOUR_TOKEN
   
   # Install and start the runner
   ./svc.sh install
   ./svc.sh start
   ```

4. **Configure Runner Labels**
   - Make sure your runner has the labels: `self-hosted`, `macos`, `x64`
   - This matches the configuration in the workflow file

### Workflow Configuration

The workflow is already configured to use self-hosted runners for macOS 12:

```yaml
test-macos-12:
  name: Test on macOS 12 (Monterey)
  runs-on: [self-hosted, macos, x64]
  timeout-minutes: 60
  continue-on-error: true
```

### Alternative: Use macOS 13+ for Compatibility Testing

If you cannot set up self-hosted runners, the workflow will:
- Skip macOS 12 testing (marked as "Self-hosted runner required")
- Still test on macOS 13, 14, and 15
- Validate that your app's deployment target is set to macOS 12.0+

### Security Considerations

- Self-hosted runners have access to your repository code
- Only use trusted machines for self-hosted runners
- Consider using dedicated CI/CD machines
- Regularly update the runner software

### Troubleshooting

1. **Runner Not Found**: Ensure the runner is online and has the correct labels
2. **Permission Issues**: Make sure the runner has necessary permissions
3. **Xcode Issues**: Install the required Xcode version (14.2) on the runner machine

## Benefits of macOS 12 Testing

- Ensures compatibility with your minimum supported version
- Catches macOS 12-specific issues early
- Validates that deprecated APIs are properly handled
- Provides confidence for users on older macOS versions
