# zoxide integration

def __zoxide_bookmark_file [] {
  (config-root | path join 'zoxide-bookmarks.json')
}

def __zoxide_read_bookmarks [] {
  let file = (__zoxide_bookmark_file)
  if ($file | path exists) {
    open $file | from json
  } else {
    {}
  }
}

def __zoxide_write_bookmarks [bookmarks: record] {
  let file = (__zoxide_bookmark_file)
  $bookmarks | to json | save --force $file
}

if ((has-cmd zoxide)) {
  def --env z [...query: string] {
    let target = (^zoxide query ...$query | complete)
    if $target.exit_code == 0 {
      let path = ($target.stdout | str trim)
      if $path != '' {
        cd $path
      }
    }
  }

  def --env zi [] {
    let target = (^zoxide query -i | complete)
    if $target.exit_code == 0 {
      let path = ($target.stdout | str trim)
      if $path != '' {
        cd $path
      }
    }
  }

  def --env zr [...query: string] {
    let target = (^zoxide query ...$query | complete)
    if $target.exit_code == 0 {
      let path = ($target.stdout | str trim)
      if $path != '' {
        cd $path
        let root = (project-root)
        if $root != null {
          cd $root
        }
      }
    }
  }

  def --env zp [...query: string] {
    zr ...$query
  }

  def zb-add [name: string, path?: string] {
    let target = ($path | default (pwd))
    let bookmarks = (__zoxide_read_bookmarks)
    __zoxide_write_bookmarks ($bookmarks | upsert $name $target)
  }

  def zb-ls [] {
    __zoxide_read_bookmarks | transpose name path
  }

  def zb-rm [name: string] {
    let bookmarks = (__zoxide_read_bookmarks)
    __zoxide_write_bookmarks ($bookmarks | reject $name)
  }

  def --env zb-go [name: string] {
    let bookmarks = (__zoxide_read_bookmarks)
    let target = ($bookmarks | get -o $name)
    if ($target | is-empty) {
      print $"Bookmark not found: ($name)"
      return
    }

    cd $target
  }

  alias zbl = zb-ls
  alias zbg = zb-go
}

