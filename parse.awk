# For some reason FS = "\|\|" didn't work, so we use a complete regexp
BEGIN { FS = "[\\|]{2,2}"; NOT_USED=0 }

function trim(v) { 
    ## Remove leading and trailing spaces (add tabs if you like) 
    sub(/^ */,"",v) 
    sub(/ *$/,"",v) 
    return v 
 } 

/^\| / {
		IMGNAME = trim($1);
		#| height="27px" | [[File:Sunflower.png|15px]]
		if (match(IMGNAME, /\[\[File:(.*\.png).*]]/, matches)) {
			IMGNAME = matches[1]
		} else {
			IMGNAME = ""
		}
		ID = trim($2);
		if(ID !~ /^[0-9]{1,3}$/) {
			if (match(ID, /<span[^>]*>[ ]*([0-9]{1,3})[ ]*<\/span>/, matches)) { 
				ID=matches[1];
			} else {
				print "Invalid ID:" ID; exit 1
			}
		}
		SYSNAME = trim($4);
		if(SYSNAME == "") { SYSNAME="minecraft:not_used"NOT_USED; NOT_USED=NOT_USED+1; } # Maybe just use "next" ?
		if(SYSNAME !~ /^[a-z_0-9]+:[a-z_0-9]+$/) {
			print "Invalid SYSNAME:" SYSNAME; exit 1;
		}
        NAME = trim($5);
		gsub("<sup>.*$","",NAME);
		NAME=trim(NAME);
		if (match(NAME, /\[\[([^|]*)]]/, matches)) {
			#print "MATCH 1:" matches[1]
            NAME=matches[1];
		} else if (match(NAME, /\[\[(.*)\|(.*)\]\]/, matches)) {
			#print "MATCH 2:" matches[2] " = " NAME
			NAME=matches[2];
        } else if (NAME ~ /[A-z ^\|]*/){
				#print "MATCH 3:" NAME
		} else {
                print "Could not guess name:" NAME; exit 1
        }
		if (IMGNAME != "") {
		if ( system("[ -f img/"IMGNAME" ] ")  == 0 ) { 
			print "File exsist, will not download" > "/dev/stderr"
		} else {
			WIKIIMGURL = "http://minecraft.gamepedia.com/File:"IMGNAME

			cmd = "wget -O - \""WIKIIMGURL"\""
			result = ""
			while ( (cmd | getline line) > 0 ){
				result = result " " line
			}
			close(cmd)
			if (match(result, /<div class="fullImageLink" id="file"><a href="(http:\/\/hydra-media.cursecdn.com\/minecraft.gamepedia.com\/)([^"]*)/, matches)) {
				IMGURL=matches[1]""matches[2] ;
				#print IMGURL
				# -N so we dont update if server image has same size and not newer
				system("cd img &&  wget -N \""IMGURL"\"")
			}
			#print "the result: " result
		}
		}
		print ID","SYSNAME","NAME","IMGNAME
		# Quickstop if we just wat to test
		#if(ID == "2") { exit 1 }
		}
