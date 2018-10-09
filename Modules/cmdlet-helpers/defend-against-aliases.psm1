
<#
Aliases declared outside your module can affect code within.
Workarounds are not guaranteed and rely on 

Usage is strange because we want the code to run within the calling module's scope,
so we intentionally return a fresh scriptblock and trust the caller to dot-source
it in their scope.

Usage:
    . (Get-AliasShadowerScriptBlock)
#>
Function Get-AliasShadowerScriptBlock {
    return [scriptblock]::create({
        param(
            [string]$uniquePrefix = "This$(Get-Random)___",
            [string[]]$dependencies
        )
        # Detect name of this module
        $function:__temp = {}
        $moduleName = (get-command __temp).modulename
        $function:__temp = $null

        # Get all Functions (public and private) declared by this module
        $allFnNames = foreach($c in (Get-Command -Type Function -Module $moduleName)) {
            $c.name
        }
        foreach($fnName in $allFnNames) {
            # Create a prefixed copy of the function.
            # This allows alias foo for function foo to instead call duplicate copy This_foo.
            . ([scriptblock]::create("`${function:$uniquePrefix$fnName} = `${function:$fnName}"))

            # Create an alias from the function's name to the duplicate copy.
            # Effectively, all attempts to invoke the function will invoke this alias. (*not* an alias
            # declared externally)
            $aliasName = $fnName
            $targetName = "$uniquePrefix$fnName"
            try {
                new-alias $aliasName $targetName -force
            } catch {
                # Possibly we could not make a new alias because a Constant AllScope alias was copied into our scope
                # Confirm that is the case, then replace the AllScope alias with our own
                $copiedAlias = get-alias -scope 0 $aliasName -EA silentlycontinue
                if($copiedAlias.options -contains 'allscope') {
                    remove-item alias:\$aliasName -force
                    new-alias $aliasName $targetName -force
                } else {
                    throw 'fatal error: alias conflicts with calling environment'
                }
            }
        }

        # aliasing commands from dependencies is easier because we can qualify them with a module name
        # Get all Functions (public and private) declared by this module
        foreach($dep in $dependencies) {
            foreach($cmdName in ((Get-Command -Module $dep).name)) {
                # Create an alias from the function's name to the fully-qualified name.
                $fullName = "$dep\$cmdName"
                new-alias $cmdName $fullName -force
                if((Get-Alias $fullName)) {
                    throw "Alias exists that will shadow fully-qualified command name.  This is insane and is not supported."
                }
            }
        }

        <#
            TODO
            If we want to be *even more paranoid* we can re-import the dependency with a random prefix.
            Then create aliases that point to the random prefix alias.
        #>
    })
}
