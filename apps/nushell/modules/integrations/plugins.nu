# Nushell plugin helpers

def nu-plugin-status [] {
  if (which plugin | is-not-empty) {
    plugin list
  } else {
    print "Current environment does not expose the plugin command."
  }
}

def nu-plugin-help [] {
  print "Install plugins per platform; do not share plugin binaries across platforms."
  print "After upgrading Nushell, check plugin compatibility and refresh the registry."
}

def nu-plugin-list [] {
  nu-plugin-status
}

def nu-plugin-add [filename: string, shell?: string] {
  if (which plugin | is-empty) {
    print "Current environment does not expose the plugin command."
    return
  }

  if ($shell | is-empty) {
    plugin add $filename
  } else {
    plugin add --shell $shell $filename
  }
}

def nu-plugin-rm [name: string, --force(-f)] {
  if (which plugin | is-empty) {
    print "Current environment does not expose the plugin command."
    return
  }

  if $force {
    plugin rm --force $name
  } else {
    plugin rm $name
  }
}

def nu-plugin-stop [name: string] {
  if (which plugin | is-empty) {
    print "Current environment does not expose the plugin command."
    return
  }

  plugin stop $name
}

def nu-plugin-registry [] {
  if ($nu.plugin-path? | is-not-empty) {
    $nu.plugin-path
  } else {
    print "No plugin registry file is configured."
  }
}

