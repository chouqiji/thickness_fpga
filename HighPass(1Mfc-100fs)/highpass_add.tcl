set mdldir [file dirname [info script]]

puts "Adding DSP Builder System highpass to project\n"

set_global_assignment -name "QIP_FILE" [file join $mdldir "highpass.qip" ]

if { [file exist [file join $mdldir "highpass_add_user.tcl" ]] } {
	source [file join $mdldir "highpass_add_user.tcl" ]
}


# Add an index file for the Librarian
set ipDir "[get_project_directory]/ip/highpass/";
if { ![file exists $ipDir] } {
	file mkdir $ipDir;
}
# Reference the file by relative path if possible
if { [file pathtype $mdldir] == "relative" } {
	set mdlIPX "../../$mdldir/highpass.ipx"
} else {
	set mdlIPX "${mdldir}/highpass.ipx"
}
set ipxFP [open "$ipDir/highpass.ipx" w]
puts $ipxFP "<library><index file='$mdlIPX'/></library>"
close $ipxFP

