#
# License: BSD 3-Clause license for the custom tclhttpd code
#
# Copyright (c) 2018, Thomas Pfarr, All rights reserved.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
#  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT #NOT LIMITED TO, THE IMPLIED WARRANTIES
#  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
#  SHALL THE #COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
#  OR BUSINESS INTERRUPTION) #HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
#  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
#  POSSIBILITY OF SUCH DAMAGE.
#
package require struct
package require inifile

global PID

::struct::queue log_q

namespace eval ::PT:: {

}

Direct_Url /editparms	::PT::/editparms
Direct_Url /showlog    ::PT::/showlog
Direct_Url /restart    ::PT::/restart
Direct_Url /updateconfig  ::PT::/updateconfig
Direct_Url /supplylog  ::PT::/supplylog

proc ::PT::/restart {} {
    global PID
	if {$PID != 0} {
	    if { [catch { close $PID } result ] } {
               puts $result
               return $html
	    } else {
		set PID 0
            }
	}
	if { [catch { set PID [open "| ./run_bridge.sh"] } result ] } {
         puts $result
	} else {
                puts "run_bridge.sh started..."
                fconfigure $PID -blocking 0 -buffering none
		fileevent $PID readable [list ::PT::pipeHandler $PID]
	}
    Doc_Redirect /showlog
}

proc ::PT::/showlog {} {
    set html ""
    append html [page::header ""]
    append html "<h3>Protothrottle Bridge log messages</H3>"
    append html [page::footer NO]
    set body {
       <div id="log_frame"></div>
       <script type="text/javascript" language="javascript" charset="utf-8">
          new Ajax.PeriodicalUpdater("log_frame", "/supplylog", {method: 'post', frequency: 5, decay: 1, encoding :''});
        </script>
    }
    append html "$body"
    append html "</body></html>"
    return "$html"
}

proc ::PT::/supplylog {} {
        set size [::log_q size]
#        puts "in supplylog, size=$size"
        if {$size > 0} {
	    set l [::log_q peek $size]
	    for {set i $size} {$i >= 0} {incr i -1} {
            set str [lindex [lindex $l $i] 1]
               append html "<font color='White'>$str</font><BR>\n"
            }
        } else {
	        append html "<font color='White'>Log is empty</font>"
        } 
        return $html
}   


proc ::PT::pipeHandler {f} {
#        puts "in pipehandler"
	if {[eof $f]} {
	 catch {close $f}
	 return Ok
	}
	if {[string equal [set line [gets $f]] ""]} {return}
        set real_text $line
#	puts "In pipeHandler, msg=$real_text"
	append text [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"] " Msg: " $real_text
        ::PT::write_log "esu_bridge" $text
}

proc ::PT::write_log {responder text} {
	::log_q put [list $responder $text]
	if {[::log_q size] > 200} {
		set discard [::log_q get 1]
    }
}

proc ::PT::getIniFileData {file} {
   global CFGID
   ::ini::commentchar "#"
   set CFGID [::ini::open $file r+]
   return [::ini::get $CFGID "configuration"]
}

proc ::PT::setIniFileData { name value } {
    global CFGID
    ::ini::set $CFGID "configuration" $name $value
}

proc ::PT::/editparms {} {
    append html [html::description "View/Modify Protothrottle configuration variables"]
    append html [page::header "View/Modify Protothrottle configuration variables"]
    set plist [::PT::getIniFileData "/tmp/protothrottle-config.txt"]
    append html "<form action='/updateconfig' method='POST'>"
    append html "<h2>Update Configuration Items</h2><br>"
    foreach {key value} $plist {
	    if {[string first "#" $key] == -1} {
               append html "$key:\n"
               set width [expr [string length $value] + 3]
               append html "<input type=text size='$width' name='${key}' value='$value'>\n"
               append html "<BR>\n"
	    }
    }
       append html "<br>"
       append html "Action: <input type='submit' name='Submit' value='Update Values'>"
       append html "<br>Action: <input type='submit' name='Cancel' value='cancel'><!--></form>"
    append html [page::footer]
    return "$html"
}

proc ::PT::/updateconfig {Submit Cancel args} {
    global CFGID
    set html ""
    if {$Cancel == "cancel"} {
       append html "Edit parameters canceled"
       append html [page::footer]
       return $html
    }
    foreach {name value} $args {
       ::PT::setIniFileData $name $value
    }
    ::ini::commit $CFGID
    ::ini::close $CFGID
    set fd [open "/tmp/protothrottle-config.txt" r]
    append html "<h3>This is a listing of the new protothrottle-config.txt file</h3><br><br>"
    while {![eof $fd]} {
       append html [gets $fd]
       append html "<br>\n"
    }
    close $fd
    append html [page::footer]
    return $html
}

set PID 0
puts "Ready to start..."
after 5000 ::PT::/restart
