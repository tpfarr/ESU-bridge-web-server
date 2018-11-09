# Tcl package index file, version 1.1
# Do NOT edit by hand.  Let tcllib install generate this file.
# Generated by tcllib installer for version 1.18

# All tcllib packages need Tcl 8 (use [namespace])
if {![package vsatisfies [package provide Tcl] 8]} {return}

# Extend the auto_path to make tcllib packages available
if {[lsearch -exact $::auto_path $dir] == -1} {
    lappend ::auto_path $dir
}

# For Tcl 8.3.1 and later, that's all we need
if {[package vsatisfies [package provide Tcl] 8.4]} {return}
if {(0 == [catch {
    package vcompare [info patchlevel] [info patchlevel]
}]) && (
    [package vcompare [info patchlevel] 8.3.1] >= 0
)} {return}

# For older Tcl releases, here are equivalent contents
# of the pkgIndex.tcl files of all the modules

if {![package vsatisfies [package provide Tcl] 8.0]} {return}


set maindir $dir
set dir [file join $maindir base64] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir cmdline] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir comm] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir counter] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir csv] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir fileutil] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir html] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir inifile] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir json] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir md5] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir md5crypt] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir mime] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir ncgi] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir sha1] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir snit] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir struct] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir textutil] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir uri] ;	 source [file join $dir pkgIndex.tcl]
set dir [file join $maindir websocket] ;	 source [file join $dir pkgIndex.tcl]
unset maindir

