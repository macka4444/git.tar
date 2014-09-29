#!/usr/bin/perl -w

#  python2perl.pl
#  Created by Mackenzie Baran on 27/09/2014.

while ($line = <>) {
    if ($line =~ /^#!/ && $. == 1) {
        # translate #! line... subs 0
        print "#!/usr/bin/perl -w\n";
    
    } elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
        # Blank & comment lines can be passed unchanged... subs 0
        print $line;

    } elsif ($line =~ /^\s*print\s*"(.*)"\s*$/) {
        # Python's print print a new-line character by default
        # so we need to add it explicitly to the Perl print statement
        # ... subs 0
        print "print \"$1\\n\";\n";
        
    } elsif ($line =~ /^\s*print\s*([^\"]*)/){
        # printing variables ... subs 1
        print "print \"\$",($1),"\\n\";\n";

    } elsif ($line =~ /^\s*(.*)\s*=\s*(.*)/){
        #deal with $ variables ...subs 1
        $sub = $2;
        if ($sub =~ /(\s*\S*\s*[\(\)\+\-\*\/]\s*)+/){
            while ($sub =~ m/(\s*\S*\s*[\+\-\*\/\%]+\s*)*/g){
                print "-->",$1,"<--\n";
            }
        }else{
            print "\$$1= $2;\n";
        }
        
    } else {
        #Lines we can't translate are turned into comments
        print "#$line\n";
        
    }
}