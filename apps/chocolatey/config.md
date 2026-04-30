cacheLocation||Cache location if not TEMP folder. Replaces `$env:TEMP` value for choco.exe process. It is highly recommended this be set to make Chocolatey more deterministic in cleanup.
commandExecutionTimeoutSeconds|2700|Default timeout for command execution. '0' for infinite.
containsLegacyPackageInstalls|true|
defaultPushSource||Default source to push packages to when running 'choco push' command.
defaultTemplateName||Default template name used when running 'choco new' command.
proxy||Explicit proxy location.
proxyBypassList||Optional proxy bypass list. Comma separated. Requires explicit proxy configured.
proxyBypassOnLocal|true|Bypass proxy for local connections. Requires explicit proxy configured.
proxyPassword||Optional proxy password. Encrypted. Requires explicit proxy and proxyUser configured.
proxyUser||Optional proxy user. Requires explicit proxy configured.
upgradeAllExceptions||A comma-separated list of package names that should not be upgraded when running `choco upgrade all'. Defaults to empty.
webRequestTimeoutSeconds|30|Default timeout for web requests.

