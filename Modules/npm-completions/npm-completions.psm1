Register-ArgumentCompleter -CommandName npm -Native -ScriptBlock {
    param($wordToComplete, $ast, $cursorPosition)
    $words = $ast.commandelements.value
    $wordToCompleteIndex = $ast.commandelements.count
    $cursorPositionInWord = 0
    foreach ($i in 0..($ast.commandelements.count - 1)) {
        $ce = $ast.commandelements[$i]
        if ($cursorPosition -ge $ce.extent.startoffset -and $cursorPosition -le $ce.extent.endoffset) {
            $wordToCompleteIndex = $i
            $cursorPositionInWord = $cursorPosition - $ce.extent.startoffset
            break
        }
    }
    # For debugging
    # echo "words = $words" "wtci = $wordToCompleteIndex" "cpiw = $cursorPositionInWord"
    # return
    function filterLikeWord { process { if ($_ -like "$wordToComplete*") { $_ } } }
    switch ($wordToCompleteIndex) {
        1 {
            write-output $npmCommandAlias.psobject.properties.name $npmCommandDescriptions.psobject.properties.name `
                help -h --help --version -l | Select -uniq | filterLikeWord | % {
                $aliasTo = $npmCommandAlias.$_
                $title = if ($aliasTo) { "$_ -> $aliasTo" } else { $_ }
                $description = if ($aliasTo) { $npmCommandDescriptions.$aliasTo } else { $npmCommandDescriptions.$_ }
                if (-not $description) { $description = $_ }
                [System.Management.Automation.CompletionResult]::new($_, $title, 'Text', $description)
            }
        }
        2 {
            switch -regex ($words[1]) {
                '^(run|run-script)$' {
                    $root = findProjectRoot 'package.json'
                    $scripts = (get-content (join-path $root 'package.json') | convertfrom-json).scripts
                    $scripts.psobject.properties.name | filterLikeWord | % {
                        [System.Management.Automation.CompletionResult]::new($_, $_, 'Text', $scripts.$_)
                    }
                }
                '^(config|c)$' {
                    write-output get set delete list edit | filterLikeWord
                }
            }
        }
        3 {
            switch -regex ($words[1]) {
                '^(config|c)$' {
                    switch -regex ($words[2]) {
                        '^(get|set)$' {
                            $allConfig = npm config list --json | convertfrom-json
                            $allConfig.psobject.properties.name | filterLikeWord | % {
                                [System.Management.Automation.CompletionResult]::new($_, $_, 'Text', "$_ = $( $allConfig.$_ )")
                            }
                        }
                    }
                }
            }
        }
    }
}
  
$npmCommandAlias = [pscustomobject]@{
    login        = 'adduser'
    'add-user'   = 'adduser'
    issues       = 'bugs'
    c            = 'config'
    set          = 'config set'
    get          = 'config get'
    'find-dupes' = 'dedupe'
    ddp          = 'dedupe'
    'dist-tags'  = 'dist-tag'
    i            = 'install'
    cit          = 'install-ci-test'
    it           = 'install-test'
    ln           = 'link'
    list         = 'ls'
    la           = 'ls'
    ll           = 'ls'
    author       = 'owner'
    rb           = 'rebuild'
    run          = 'run-script'
    s            = 'search'
    se           = 'search'
    find         = 'search'
    t            = 'test'
    tst          = 'test'
    remove       = 'uninstall'
    rm           = 'uninstall'
    r            = 'uninstall'
    un           = 'uninstall'
    unlink       = 'uninstall'
    up           = 'update'
    upgrade      = 'update'
    info         = 'view'
    show         = 'view'
    v            = 'view'
}
$npmCommandDescriptions = @'
  {
    "dist-tag":  "Add, remove, and enumerate distribution tags on a package:",
    "test":  "This runs a package\u0027s \"test\" script, if one was provided.",
    "view":  "This command shows data about a package and prints it to the stream referenced by the outfd config, which defaults to stdout.",
    "dedupe":  "Searches the local package tree and attempts to simplify the overall structure by moving dependencies further up the tree, where they can be more effectively shared by multiple dependent packages.",
    "ping":  "Ping the configured or given npm registry and verify authentication. If it works it will output something like:",
    "stop":  "This runs a package\u0027s \"stop\" script, if one was provided.",
    "link":  "Package linking is a two-step process.",
    "stars":  "If you have starred a lot of neat things and want to find them again quickly this command lets you do just that.",
    "adduser":  "Create or verify a user named \u003cusername\u003e in the specified registry, and save the credentials to the .npmrc file. If no registry is specified, the default registry will be used (see npm-config).",
    "token":  "This list you list, create and revoke authentication tokens.",
    "shrinkwrap":  "This command repurposes package-lock.json into a publishable npm-shrinkwrap.json or simply creates a new one. The file created and updated by this command will then take precedence over any other existing or future package-lock.json files. For a detailed explanation of the design and purpose of package locks in npm, see npm-package-locks.",
    "explore":  "Spawn a subshell in the directory of the installed package specified.",
    "install-test":  "This command runs an npm install followed immediately by an npm test. It takes exactly the same arguments as npm install.",
    "config":  "npm gets its config settings from the command line, environment variables, npmrc files, and in some cases, the package.json file.",
    "help-search":  "This command will search the npm markdown documentation files for the terms provided, and then list the results, sorted by relevance.",
    "audit":  "The audit command submits a description of the dependencies configured in your project to your default registry and asks for a report of known vulnerabilities. The report returned includes instructions on how to act on this information.",
    "rebuild":  "This command runs the npm build command on the matched folders. This is useful when you install a new version of node, and must recompile all your C++ addons with the new binary.",
    "access":  "Used to set access controls on private packages.",
    "owner":  "Manage ownership of published packages.",
    "start":  "This runs an arbitrary command specified in the package\u0027s \"start\" property of its \"scripts\" object. If no \"start\" property is specified on the \"scripts\" object, it will run node server.js.",
    "prune":  "This command removes \"extraneous\" packages. If a package name is provided, then only packages matching one of the supplied names are removed.",
    "docs":  "This command tries to guess at the likely location of a package\u0027s documentation URL, and then tries to open it using the --browser config param. You can pass multiple package names at once. If no package name is provided, it will search for a package.json in the current folder and use the name property.",
    "deprecate":  "This command will update the npm registry entry for a package, providing a deprecation warning to all who attempt to install it.",
    "publish":  "Publishes a package to the registry so that it can be installed by name. All files in the package directory are included if no local .gitignore or .npmignore file exists. If both files exist and a file is ignored by .gitignore but not by .npmignore then it will be included. See npm-developers for full details on what\u0027s included in the published package, as well as details on how the package is built.",
    "doctor":  "npm doctor runs a set of checks to ensure that your npm installation has what it needs to manage your JavaScript packages. npm is mostly a standalone tool, but it does have some basic requirements that must be met:",
    "root":  "Print the effective node_modules folder to standard out.",
    "help":  "If supplied a topic, then show the appropriate documentation page.",
    "repo":  "This command tries to guess at the likely location of a package\u0027s repository URL, and then tries to open it using the --browser config param. If no package name is provided, it will search for a package.json in the current folder and use the name property.",
    "install":  "This command installs a package, and any packages that it depends on. If the package has a package-lock or shrinkwrap file, the installation of dependencies will be driven by that, with an npm-shrinkwrap.json taking precedence if both files exist. See package-lock.json and npm-shrinkwrap.",
    "logout":  "When logged into a registry that supports token-based authentication, tell the server to end this token\u0027s session. This will invalidate the token everywhere you\u0027re using it, not just for the current environment.",
    "restart":  "This restarts a package.",
    "uninstall":  "This uninstalls a package, completely removing everything npm installed on its behalf.",
    "unpublish":  "This removes a package version from the registry, deleting its entry and removing the tarball.",
    "version":  "Run this in a package directory to bump the version and write the new data back to package.json, package-lock.json, and, if present, npm-shrinkwrap.json.",
    "run-script":  "This runs an arbitrary command from a package\u0027s \"scripts\" object. If no \"command\" is provided, it will list the available scripts. run[-script] is used by the test, start, restart, and stop commands, but can be called directly, as well. When the scripts in the package are printed out, they\u0027re separated into lifecycle (test, start, restart) and directly-run scripts.",
    "create":  "npm gets its config settings from the command line, environment variables, npmrc files, and in some cases, the package.json file.",
    "unstar":  "This removes a package version from the registry, deleting its entry and removing the tarball.",
    "bin":  "Print the folder where npm will install executables.",
    "whoami":  "Print the username config to standard output.",
    "update":  "This command will update all the packages listed to the latest version (specified by the tag config), respecting semver.",
    "outdated":  "This command will check the registry to see if any (or, specific) installed packages are currently outdated.",
    "bugs":  "This command tries to guess at the likely location of a package\u0027s bug tracker URL, and then tries to open it using the --browser config param. If no package name is provided, it will search for a package.json in the current folder and use the name property.",
    "prefix":  "Print the local prefix to standard out. This is the closest parent directory to contain a package.json file unless -g is also specified.",
    "team":  "Used to manage teams in organizations, and change team memberships. Does not handle permissions for packages.",
    "pack":  "For anything that\u0027s installable (that is, a package folder, tarball, tarball url, [email protected], [email protected], name, or scoped name), this command will fetch it to the cache, and then copy the tarball to the current working directory as \u003cname\u003e-\u003cversion\u003e.tgz, and then write the filenames out to stdout.",
    "profile":  "Change your profile information on the registry. This not be available if you\u0027re using a non-npmjs registry.",
    "init":  "npm init \u003cinitializer\u003e can be used to set up a new or existing npm package.",
    "cache":  "Used to add, list, or clean the npm cache folder.",
    "ddp":  "npm gets its config settings from the command line, environment variables, npmrc files, and in some cases, the package.json file.",
    "ci":  "This command is similar to npm-install, except it\u0027s meant to be used in automated environments such as test platforms, continuous integration, and deployment. It can be significantly faster than a regular npm install by skipping certain user-oriented features. It is also more strict than a regular install, which can help catch errors or inconsistencies caused by the incrementally-installed local environments of most npm users.",
    "ls":  "This command will print to stdout all the versions of packages that are installed, as well as their dependencies, in a tree-structure.",
    "completion":  "Enables tab-completion in all npm commands.",
    "hook":  "Allows you to manage npm hooks, including adding, removing, listing, and updating.",
    "search":  "Search the registry for packages matching the search terms. npm search performs a linear, incremental, lexically-ordered search through package metadata for all files in the registry. If color is enabled, it will further highlight the matches in the results.",
    "star":  "\"Starring\" a package means that you have some interest in it. It\u0027s a vaguely positive way to show that you care.",
    "edit":  "Opens the package folder in the default editor (or whatever you\u0027ve configured as the npm editor config -- see npm-config.)"
  }
'@ | convertfrom-json
