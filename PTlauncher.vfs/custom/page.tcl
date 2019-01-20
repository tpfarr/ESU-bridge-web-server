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

# Tcl Httpd local site templates

package require http

package provide page 1.0

namespace eval page {
    namespace export *
}

# page::contents
#
#	Define the site contents
#
# Arguments:
#	list	List of URL, labels for each page in the site
#
# Side Effects:
#	Records the site structure

proc page::contents {list} {
    variable contents $list
}

# page::header
#
#	Generate HTML for the standard page header
#
# Arguments:
#	title	The page title
#
# Results:
#	HTML for the page header.

proc page::header {title} {
    page::SetLevels $title
    set html ""
    append html "<html><head>\n"
    append html "<link rel='stylesheet' type='text/css' href='/css/table.css' />\n"
    append html "<title>$title</title></head>\n"
    append html "<table cellpadding=0 cellspacing=0 border=0 width=100%>\n"
    append html "<tr> \
	[html::cell align=left  "<a href=/><img src=/images/ise-logo-new.png border=0 height='75' width='75' alt='Home'></a>"] \
	[html::cell "" "<h2>$title \(on:$::env(SERVER_NAME)\)</h2>"] \
	</tr>"
    append html "</table>"
    append html "<hr>"
    append html "[html::font]\n"

    return $html
}

proc page::singleheader {title} {
    page::SetLevels $title
    set html ""
    append html "<title>$title</title></head>\n"
    append html "<table cellpadding=0 cellspacing=0 border=0 width=100%>\n"
    append html "<tr> \
	[html::cell align=left  "<img src=/images/ise-logo-new.png border=0 height='75' width='75'>"] \
	[html::cell "" "<h2>$title \(on:$::env(SERVER_NAME)\)</h2>"] \
	</tr>"
    append html "</table>"
    append html "<hr>"
    append html [html::font]\n
    return $html
}

proc page::logheader {title} {
    page::SetLevels $title
    set html "<html><head><title>$title</title>\n"
       append html "<style type='text/css'>\n\
                p, h1, h2, h3, h4,h5,h6,li,dl \{\n\
                    font-family: Tahoma,Verdana\;\n\
                \}\n\
                hr \{\n\
	                color: white;\n\
	                background-color: black;\n\
	                width: 100%;\n\
	                height: 2px;\n\
	                margin-left:auto;\n\
	                margin-right:auto;\n\
                \}\n\                
                </style>\n"
    append html "</head>\n"
    append html "<body bgcolor='black' text='white'>\n"
    append html "<table cellpadding=0 cellspacing=0 border=0 width=100%>\n"
    append html "<tr> \
	[html::cell align=left  "      <br>"] \
	[html::cell "" "<h2>$title \(on:$::env(SERVER_NAME)\)</h2>"] \
	</tr>"
    append html "</table>"
    append html "<hr><p>"
    return $html
}        

# page::SetLevels
#
#	Map the page title to a hierarchy location in the site for the page.
#
# Arguments:
#	title	The page title
#
# Side Effects:
#	Sets the level namespace variables

proc page::SetLevels {title} {
    variable level
}

# page::footer
#
#	Generate HTML for the standard page footer
#
# Arguments:
#	none
#
# Results:
#	HTML for the page footer.

proc page::footer { {close YES} } {
    variable contents
    append html "<!-- $contents -->\n"
    append html "<table cellpadding=0 cellspacing=2 border=0 width=100%>\n"
    append html "<hr>"
    append html <tr>[html::cell "" [html::minorMenu $contents </font></td><td>[html::font]]]</tr>\n
    append html </table>\n
    if {$close == "YES"} {
    	append html "</body>\n</html>\n"
	}
    return $html
}



