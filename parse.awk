# For some reason FS = "\|\|" didn't work, so we use a complete regexp
BEGIN { FS = "[\|]{2,2}"; };
{ print "1:" $0 "\n2: " $2; }
