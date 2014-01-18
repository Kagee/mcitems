# For some reason FS = "\|\|" didn't work, so we use a complete regexp
BEGIN { FS = "[\\|]{2,2}"; NOT_USED=0 }

function trim(v) { 
    ## Remove leading and trailing spaces (add tabs if you like) 
    sub(/^ */,"",v) 
    sub(/ *$/,"",v) 
    return v 
 } 

# https://github.com/acmeism/RosettaCodeData/blob/master/Task/URL-decoding/AWK/url-decoding.awk
function hex2dec(s,  num) {
	    num = index("0123456789ABCDEF",toupper(substr(s,length(s)))) - 1
		    sub(/.$/,"",s)
			    return num + (length(s) ? 16*hex2dec(s) : 0)
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
		gsub(" ","_", IMGNAME)
		if ( system("[ -f \"img/"IMGNAME"\" ] ")  == 0 ) { 
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
				result = matches[2];
				if (match(result, /([^/]+)$/, matches)) {
					if (matches[1] != IMGNAME) {
						NEWNAME = matches[1]
						# https://github.com/acmeism/RosettaCodeData/blob/master/Task/URL-decoding/AWK/url-decoding.awk
						while (match(NEWNAME,/%/)) {
					      L = substr(NEWNAME,1,RSTART-1) # chars to left of "%"
					      M = substr(NEWNAME,RSTART+1,2) # 2 chars to right of "%"
					      R = substr(NEWNAME,RSTART+3)   # chars to right of "%xx"
					      NEWNAME = sprintf("%s%c%s",L,hex2dec(M),R)
					    }
						#print "NEW NAME: "NEWNAME " was " IMGNAME
						IMGNAME = NEWNAME
					}
				}
				# -N so we dont update if server image has same size and not newer
				system("cd img &&  wget -N \""IMGURL"\"")
			}
			#print "the result: " result
		}
		}
		printf "%-4s %-45s %-30s %s\n", ID, SYSNAME, NAME, IMGNAME
		#print ID"\t"SYSNAME"\t"NAME"\t"IMGNAME
		# Quickstop if we just wat to test
		#if(ID == "2") { exit 1 }
		}
