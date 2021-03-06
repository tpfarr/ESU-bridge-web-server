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
# Modified 1-19-2019 - T. Pfarr - Websocket interface for log display update.
# 
package require struct
package require inifile
package require websocket

global PID
global PAUSE

::struct::queue log_q
::struct::queue initialization_q

namespace eval ::PT:: {

}

Direct_Url /editparms	::PT::/editparms
Direct_Url /showlog    ::PT::/showlog
Direct_Url /restart    ::PT::/restart
Direct_Url /updateconfig  ::PT::/updateconfig
Direct_Url /data ::PT::/data
Url_PrefixInstall /supplylog [list ::PT::/supplylog /supplylog]

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
                fconfigure $PID -blocking 0 -buffering none
		fileevent $PID readable [list ::PT::pipeHandler $PID]
	}
    Doc_Redirect /showlog
}

proc ::PT::/showlog {} {
    set html ""
    append html [page::header "PT Bridge Log"]
    append html "Pause/Resume display: <input id='btnPause' type='button' value = 'Pause' onclick ='onPauseClick()'>"
    append html [page::footer NO]
    set body {
       <script type="text/javascript" language="javascript" charset="utf-8">
          var logSocket = null;
          var paused = false;
          var log_q = new Queue();
          var content = "";

          function onPauseClick() {
              if (paused) {
                  paused = false;
                  document.getElementById("btnPause").value = "Pause";
              } else {
                  paused = true;
                  document.getElementById("btnPause").value = "Resume";
              }
          }
    }
    append html "$body"
    append html "logSocket = new WebSocket(\"ws://$::env(SERVER_NAME):$::env(SERVER_PORT)/supplylog\", \"statProto\");"
    set body {
          logSocket.onmessage = function(event) {
              if (paused) {
                   log_q.enqueue(event.data);
                   if (log_q.getLength() > 1000) {
                      content = queue.dequeue();
                   }
              } else {
                   while (log_q.getLength() > 0) {
                      content = log_q.dequeue() + "\r\n" + document.getElementById("log_frame").value;
                      document.getElementById("log_frame").value = content;
                   }
                      content = event.data + "\r\n" + document.getElementById("log_frame").value;
                      document.getElementById("log_frame").value = content;
              }
          };
        </script>
    }
    append html "$body\n"
    append html "<textarea id='log_frame' readonly rows='50' cols='100'></textarea>\n"
    append html "</body>\n"
    append html "</html>\n"
    return "$html"
}  

proc ::PT::/supplylog {prefix sock suffix} {
	upvar #0 Httpd$sock data
#       foreach item [array name data] { puts "$item" }
#	puts "In /supplylog"
#	::websocket::loglevel debug
	::websocket::server $sock
	::websocket::live $sock "/supplylog" ::PT::HandleStats statProto
	set wstest [::websocket::test $sock $sock "/supplylog" "$data(headerlist)" "$data(query)"]
	if {$wstest == 1} {
		Httpd_Suspend $sock 0
		::websocket::upgrade $sock
	} else {
		Httpd_ReturnData $sock text/html "Not a valid Websocket connection!"
	}
}

proc ::PT::HandleStats {sock type msg} {
        global STREAMS
	switch $type {
	    connect { set STREAMS($sock) "Initial" ; return }
	    timeout { return }
            error { return }
	    close { unset -nocomplain STREAMS($sock) ; return}
	    disconnect { unset -nocomplain STREAMS($sock) ; return }
	    binary { return }
	    text { return }
            ping { puts "ping" ; return }
	    pong { puts "pong" ; return }
	}
}

proc ::PT::sendLog {} {
        global STREAMS
        global PAUSE
#       puts "In sendlog"
	set socklist [array names STREAMS]
	if {[llength $socklist] > 0} {
#                puts "In sendlog,$socklist"
                set PAUSE false
#               puts "In sendlog, log_q size=[::log_q size]"
		foreach sock $socklist {
		    if {$STREAMS($sock) eq "Initial"} {
                        if {[::initialization_q size] > 0} {
		           set msg_list [::initialization_q peek [::initialization_q size]]
		           foreach init_msg $msg_list {
	         	      if {[::websocket::send $sock "text" "$init_msg"] < 0} {
			         puts "$sock socket blocked or error, removed from active list"
			         unset -nocomplain STREAMS($sock)
			         break 
			      }
                           }
		        }
		        catch {set STREAMS($sock) "InProgress"}
		    }
                 }
                 while {[::log_q size] > 0} {
	             set msg [::log_q peek 1]
                     foreach sock $socklist {
			 if {[::websocket::send $sock "text" "$msg"] < 0} {
			    puts "$sock socket blocked or error, removed from active list"
			    unset -nocomplain STREAMS($sock)
                            break
			 }
                      }
                      catch {set discard [::log_q get 1]}
                  }
	} else {
           set PAUSE true
        }
	after 1000 ::PT::sendLog
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
	append text [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"] ": $real_text"
        ::PT::write_log $text
}

proc ::PT::write_log {text} {
    global PAUSE
    ::initialization_q put $text
    if {!$PAUSE} {
        ::log_q put $text
    }
    if {[::log_q size] > 100} {
	set discard [::log_q get 1]
    }
    if {[::initialization_q size] >1000} {
	set discard [::initialization_q get 1]
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
set PAUSE true
puts "Ready to start..."
after 5000 ::PT::/restart
::PT::sendLog
